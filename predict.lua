require 'nn'
require 'nngraph'
require 'utils.video'

torch.setdefaulttensortype('torch.FloatTensor')

cmd = torch.CmdLine()
cmd:text()
cmd:text('Predict who is walking in the clip')
cmd:text()
cmd:text('Options')
cmd:option('-video_dir','','path to directory with video frames')
cmd:option('-ext','png','path to directory with video frames')
cmd:option('-model','','path to model file')
cmd:text()

-- parse input params
opt = cmd:parse(arg)

if opt.video_dir == '' or opt.model == '' then
  error('No video directory or model file specified')
end

checkpoint = torch.load(opt.model)
cnn = checkpoint.models.cnn
rnn = checkpoint.models.rnn

x = process_directory(opt.video_dir, opt.ext, -1, true)

-- the initial state of the cell/hidden states
local init_state = {}
for L=1,2 do-- TODO checkpoint.opt.num_layers do
    local h_init = torch.zeros(64)--checkpoint.opt.rnn_size)
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
    rnn_state = {}
    for i = 1,#init_state do table.insert(rnn_state, lst[i]) end
    prediction = lst[#lst]
    ct = ct + 1
end

prediction = torch.exp(prediction)
for i = 1, prediction:size(2) do
  io.write(string.format('%f ', prediction[1][i]))
end
io.flush()
print()
