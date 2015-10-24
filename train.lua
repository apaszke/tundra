require 'nn'
require 'optim'

local LSTM = require 'modules.LSTM'
local model_utils = require 'utils.model_utils'
local BatchLoader = require 'utils.BatchLoader'

torch.setdefaulttensortype('torch.FloatTensor')

cmd = torch.CmdLine()
cmd:text()
cmd:text('Train a character-level language model')
cmd:text()
cmd:text('Options')
-- data
cmd:option('-data_dir','data','data directory')
cmd:option('-checkpoint_dir','checkpoint','checkpoint directory')
-- model params
cmd:option('-rnn_size', 64, 'size of LSTM internal state')
cmd:option('-num_layers', 2, 'number of layers in the LSTM')
-- optimization
cmd:option('-optim_algo','rmsprop','optimization algorithm')
cmd:option('-learning_rate',2e-3,'learning rate')
cmd:option('-learning_rate_decay',0.97,'learning rate decay')
cmd:option('-learning_rate_decay_after',10,'in number of epochs, when to start decaying the learning rate')
cmd:option('-decay_rate',0.95,'decay rate for rmsprop')
cmd:option('-dropout',0,'dropout for regularization, used after each RNN hidden layer. 0 = no dropout')
cmd:option('-seq_length',75,'number of timesteps to unroll for')
cmd:option('-warmup_length',80,'number of timesteps to unroll for')
cmd:option('-max_epochs',30,'number of full passes through the training data')
cmd:option('-grad_clip',5,'clip gradients at this value')

cmd:option('-init_from', '', 'initialize network parameters from checkpoint at this path')
-- bookkeeping
cmd:option('-seed',123,'torch manual random number generator seed')
cmd:option('-print_every',1,'how many steps/minibatches between printing out the loss')
cmd:option('-eval_val_every',15,'every how many iterations should we evaluate on validation data?')
-- GPU/CPU
cmd:option('-gpuid',0,'which gpu to use. -1 = use CPU')
cmd:text()

-- parse input params
opt = cmd:parse(arg)
torch.manualSeed(opt.seed)

-- load GPU
if opt.gpuid >= 0 then
    local ok, cunn = pcall(require, 'cunn')
    local ok2, cutorch = pcall(require, 'cutorch')
    if not ok then print('package cunn not found!') end
    if not ok2 then print('package cutorch not found!') end
    if ok and ok2 then
        print('using CUDA on GPU ' .. opt.gpuid .. '...')
        cutorch.setDevice(opt.gpuid + 1) -- note +1 to make it 0 indexed! sigh lua
        cutorch.manualSeed(opt.seed)
    else
        print('If cutorch and cunn are installed, your CUDA toolkit may be improperly configured.')
        print('Check your CUDA toolkit installation, rebuild cutorch and cunn, and try again.')
        print('Falling back on CPU mode')
        opt.gpuid = -1 -- overwrite user setting
    end
end

-- define CNN
local cnn = nn.Sequential()
cnn:add( nn.SpatialConvolution(1, 20, 5, 5, 2, 2) )
cnn:add( nn.Dropout(opt.dropout) )
cnn:add( nn.ReLU() )
cnn:add( nn.SpatialConvolution(20, 20, 5, 5, 2, 2) )
cnn:add( nn.Dropout(opt.dropout) )
cnn:add( nn.ReLU() )
cnn:add( nn.SpatialConvolution(20, 20, 5, 5, 3, 3) )
cnn:add( nn.Dropout(opt.dropout) )
cnn:add( nn.ReLU() )
cnn:add( nn.SpatialConvolution(20, 800, 18, 34) )
cnn:add( nn.Dropout(opt.dropout) )
cnn:add( nn.ReLU() )
cnn:add( nn.SpatialConvolution(800, 600, 1, 1) )
cnn:add( nn.Dropout(opt.dropout) )
cnn:add( nn.ReLU() )
cnn:add( nn.View(1, 600) )
-- output is of size 1x600

local loader = BatchLoader.create(opt.data_dir)

local do_random_init = true
local start_iter = 1
local forget_gates = {}
if string.len(opt.init_from) > 0 then
    print('not supported. exiting.')
    exit()
else
    print('creating an LSTM with ' .. opt.rnn_size .. ' units in ' .. opt.num_layers .. ' layers')
    protos = {}
    protos.rnn, forget_gates = LSTM.create(600, 3, opt.rnn_size, opt.num_layers, opt.dropout)
    protos.criterion = nn.ClassNLLCriterion()
end

-- the initial state of the cell/hidden states
local init_state = {}
for L=1,opt.num_layers do
    local h_init = torch.zeros(opt.rnn_size)
    if opt.gpuid >=0 then h_init = h_init:cuda() end
    table.insert(init_state, h_init:clone())
    table.insert(init_state, h_init:clone())
end

-- ship the model to the GPU if desired
if opt.gpuid >= 0 then
    for k,v in pairs(protos) do v:cuda() end
    cnn:cuda()
end

-- put the above things into one flattened parameters tensor
print('combining params')
local params, grad_params = model_utils.combine_all_parameters(protos.rnn, cnn)

-- initialization
if do_random_init then
    params:uniform(-0.08, 0.08) -- small numbers uniform
    for i = 1, #forget_gates do -- initialize forget gate bias
      forget_gates[i].data.module.bias:sub(opt.rnn_size + 1, opt.rnn_size * 2):fill(1.5)
    end
end

print('number of parameters in total: ' .. params:nElement())
-- make a bunch of clones after flattening, as that reallocates memory
local clones = {}
for name,proto in pairs(protos) do
    print('cloning ' .. name)
    clones[name] = model_utils.clone_many_times(proto, opt.seq_length, 5)
end

collectgarbage()

-- evaluate the loss over an entire split
function eval_val()
    print('evaluating loss over validation set')

    local loss = 0
    local rnn_state = {[0] = init_state}

    -- iterate over batches in the split
    local ct = 0
    local loss_ct = 0
    for i = 1, loader:num_validation_batches() do
        -- fetch a batch
        local x, y = loader:next_validation_batch()
        if opt.gpuid >= 0 then -- ship the input arrays to GPU
            x = x:float():cuda()
        end
        -- forward pass
        for t = 1,opt.seq_length do
            clones.rnn[t]:evaluate() -- for dropout proper functioning
            cnn:evaluate()
            local cnn_out = cnn:forward(x:sub(t,t))
            local lst = clones.rnn[t]:forward{cnn_out, unpack(rnn_state[t-1])}
            rnn_state[t] = {}
            for i = 1,#init_state do table.insert(rnn_state[t], lst[i]) end
            prediction = lst[#lst]
            if t > opt.warmup_length then
              loss_ct = loss_ct + 1
              loss = loss + clones.criterion[t]:forward(prediction, y)
            end
        end
        ct = ct + 1
        if ct % 10 == 0 then
            print('Evaluated: ' .. ct .. 'batches')
        end
    end

    loss = loss / loss_ct
    return loss
end

function clone_list(tensor_list, zero_too)
    -- utility function. TODO: move away to some utils file?
    -- takes a list of tensors and returns a list of cloned tensors
    local out = {}
    for k,v in pairs(tensor_list) do
        out[k] = v:clone()
        if zero_too then out[k]:zero() end
    end
    return out
end

-- do fwd/bwd and return loss, grad_params
local init_state_global = clone_list(init_state)
function feval(x)
    if x ~= param then
        params:copy(x)
    end
    grad_params:zero()

    ------------------ get minibatch -------------------
    local x, y = loader:next_training_batch()
    if opt.gpuid >= 0 then -- ship the input arrays to GPU
        -- have to convert to float because integers can't be cuda()'d
        x = x:float():cuda()
    end
    ------------------- forward pass -------------------
    local rnn_state = {[0] = init_state_global}
    local predictions = {}           -- softmax outputs
    local loss = 0
    for t=1,opt.seq_length do
        -- set training flag (for dropout)
        clones.rnn[t]:training()
        cnn:training()
        -- forward the data
        local cnn_out = cnn:forward(x:sub(t,t))
        local lst = clones.rnn[t]:forward{cnn_out, unpack(rnn_state[t-1])}
        -- save RNN state
        rnn_state[t] = {}
        -- print(rnn_state[t-1][1])
        for i=1,#init_state do table.insert(rnn_state[t], lst[i]) end -- without the output
        predictions[t] = lst[#lst] -- last element is the prediction
        -- forward through the criterion only if the warmup period has passed
        if t > opt.warmup_length then
          loss = loss + clones.criterion[t]:forward(predictions[t], y)
        end
    end
    local tmp = torch.exp(predictions[opt.seq_length])
    print(string.format('%d: %f %f %f', y, tmp[1][1], tmp[1][2], tmp[1][3]))
    loss = loss / (opt.seq_length - opt.warmup_length + 1)
    ------------------ backward pass -------------------
    -- initialize gradient at time t to be zeros (there's no influence from future)
    local drnn_state = {[opt.seq_length] = clone_list(init_state, true)} -- true also zeros the clones
    for t=opt.seq_length,opt.warmup_length,-1 do
        -- backprop through loss, and softmax/linear
        -- criterion gradient
        local doutput_t = clones.criterion[t]:backward(predictions[t], y)
        table.insert(drnn_state[t], doutput_t)
        -- refresh cnn output
        local cnn_out = cnn:forward(x:sub(t,t))
        -- lstm gradient
        local dlst = clones.rnn[t]:backward({cnn_out, unpack(rnn_state[t-1])}, drnn_state[t])
        -- cnn gradient
        cnn:backward(x:sub(t,t), dlst[1])
        drnn_state[t-1] = {}
        for k,v in pairs(dlst) do
            if k > 1 then -- k == 1 is gradient on x, which we dont need
                -- derivatives of the state, starting at index 2. I know...
                drnn_state[t-1][k-1] = v
            end
        end
    end
    ------------------------ misc ----------------------
    -- clip gradient element-wise
    grad_params:div(opt.seq_length-opt.warmup_length+1)
    grad_params:clamp(-opt.grad_clip, opt.grad_clip)
    return loss, grad_params
end

-- start optimization here
local train_losses = train_losses or {}
local val_losses = val_losses or {}

local optim_fun, optim_state
if opt.optim_algo == 'rmsprop' then
    optim_fun = optim.rmsprop
    optim_state = {learningRate = opt.learning_rate, alpha = opt.decay_rate}
elseif opt.optim_algo == 'adadelta' then
    optim_fun = optim.adadelta
    optim_state = {rho = 0.95, eps = 1e-7}
end

local iterations = opt.max_epochs * loader:num_training_batches()
local loss0 = nil
for i = start_iter, iterations do
    local epoch = i / loader:num_training_batches()

    local timer = torch.Timer()
    local _, loss = optim_fun(feval, params, optim_state)
    local time = timer:time().real

    local train_loss = loss[1] -- the loss is inside a list, pop it
    train_losses[i] = train_loss

    if i % opt.print_every == 0 then
        local grad_norm = grad_params:norm()
        local param_norm = params:norm()
        print(string.format("%d/%d (epoch %.3f), train_loss = %6.8f, grad/param norm = %6.4e, param norm = %.2e time/batch = %.2fs",
                i, iterations, epoch, train_loss, grad_norm / param_norm, param_norm, time))
        local ct = 0;
    end

    -- exponential learning rate decay
    if i % (math.floor(loader:num_training_batches()) / 2) == 0 and opt.learning_rate_decay < 1 then
        if epoch >= opt.learning_rate_decay_after then
            local decay_factor = opt.learning_rate_decay
            optim_state.learningRate = optim_state.learningRate * decay_factor -- decay it
            print('decayed learning rate by a factor ' .. decay_factor .. ' to ' .. optim_state.learningRate)
        end
    end

    -- every now and then or on last iteration
    if i % opt.eval_val_every == 0 or i == iterations then
        val_loss = eval_val()
        print('\tvalidation loss: ' .. val_loss)
        local savefile = string.format('%s/cp_%.4f_epoch%.2f.t7', opt.checkpoint_dir, val_loss, epoch)
        print('\tsaving checkpoint to file ' .. savefile)
        local checkpoint = {}
        checkpoint.models = {}
        checkpoint.models.cnn = cnn
        checkpoint.models.rnn = protos.rnn
        torch.save(savefile, checkpoint);
    end

    if i % 10 == 0 then collectgarbage() end

    -- handle early stopping if things are going really bad
    if loss[1] ~= loss[1] then
        print('loss is NaN.  This usually indicates a bug.  Please check the issues page for existing issues, or create a new issue, if none exist.  Ideally, please state: your operating system, 32-bit/64-bit, your blas version, cpu/cuda/cl?')
        break -- halt
    end
    if loss0 == nil then loss0 = train_losses[1] end
    if train_losses[1] > loss0 * 3 then
        print('loss is exploding, aborting.')
        break -- halt
    end
end


print 'TRAINING DONE'
