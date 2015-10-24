require 'nn'

cmd = torch.CmdLine()
cmd:text()
cmd:text('Predict who is walking in the clip')
cmd:text()
cmd:text('Options')
-- data

cmd:option('-video_dir','','path to directory with video frames')
cmd:option('-ext','png','path to directory with video frames')
cmd:option('-model','','path to model file')
cmd:option()
cmd:text()

-- parse input params
opt = cmd:parse(arg)
torch.manualSeed(opt.seed)

if opt.video_dir == '' or opt.model == '' then
  exit()
end

checkpoint = torch.load(opt.model)
cnn = checkpoint.models.cnn
rnn = checkpoint.models.rnn

preprocessing = torch.load(path.join('data', 'preprocessing.t7'))
files = {}
for file in paths.files(opt.video_dir) do
  -- We only load files that match the extension
  if file:find(opt.ext .. '$') then
    -- and insert the ones we care about in our table
    table.insert(files, paths.concat(opt.video_dir, file))
  end
end

-- check files
if #files == 0 then
  error('Given directory does not contain any files of type: ' .. opt.ext)
end

fullTensor = torch.Tensor(#files, )

-- go over all files in directory. We use an iterator, paths.files().
for file in paths.files(tmp_dir) do
  -- We only load files that match the extension
  if file:find(opt.ext .. '$') then
    -- and insert the ones we care about in our table
    table.insert(files, paths.concat(tmp_dir, file))
  end
end


-- the initial state of the cell/hidden states
local init_state = {}
for L=1,opt.num_layers do
    local h_init = torch.zeros(opt.rnn_size)
    if opt.gpuid >=0 then h_init = h_init:cuda() end
    table.insert(init_state, h_init:clone())
    table.insert(init_state, h_init:clone())
end

local rnn_state = init_state
local ct = 0
local prediction
for t = 1, x:size(1) do
    -- forward pass
    rnn:evaluate() -- for dropout proper functioning
    cnn:evaluate()
    local cnn_out = cnn:forward(x:sub(t,t))
    local lst = rnn:forward{cnn_out, unpack(rnn_state)}
    rnn_state[ = {}
    for i = 1,#init_state do table.insert(rnn_state, lst[i]) end
    prediction = lst[#lst]
    ct = ct + 1
    if ct % 50 == 0 then
        print('Evaluated: ' .. ct .. 'steps')
    end
end

print(prediction)
