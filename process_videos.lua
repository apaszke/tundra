require 'torch'
require 'lfs'
require 'image'
require 'xlua'
require 'utils.video'

torch.setdefaulttensortype('torch.FloatTensor')

-- INIT

-- video: video name
-- label: label of person
-- type: training/validation
videos = {
	[1] = {['video'] = 'IMG_4428.m4v', ['label'] = 1, ['type'] = 'training'},
	[2] = {['video'] = 'IMG_4429.m4v', ['label'] = 1, ['type'] = 'training'},
	[3] = {['video'] = 'IMG_4430.m4v', ['label'] = 1, ['type'] = 'validation'},
	[4] = {['video'] = 'IMG_4431.m4v', ['label'] = 1, ['type'] = 'training'},
	[5] = {['video'] = 'IMG_4432.m4v', ['label'] = 1, ['type'] = 'training'},

	[6] = {['video'] = 'IMG_4433.m4v', ['label'] = 2, ['type'] = 'training'},
	[7] = {['video'] = 'IMG_4434.m4v', ['label'] = 2, ['type'] = 'training'},
	[8] = {['video'] = 'IMG_4435.m4v', ['label'] = 2, ['type'] = 'training'},
	[9] = {['video'] = 'IMG_4436.m4v', ['label'] = 2, ['type'] = 'training'},
	[10] = {['video'] = 'IMG_4437.m4v', ['label'] = 2, ['type'] = 'training'},

	[11] = {['video'] = 'IMG_4439.m4v', ['label'] = 3, ['type'] = 'training'},
	[12] = {['video'] = 'IMG_4440.m4v', ['label'] = 3, ['type'] = 'training'},
	[13] = {['video'] = 'IMG_4441.m4v', ['label'] = 3, ['type'] = 'training'},
	[14] = {['video'] = 'IMG_4442.m4v', ['label'] = 3, ['type'] = 'training'},
	[15] = {['video'] = 'IMG_4443.m4v', ['label'] = 3, ['type'] = 'training'},
	[16] = {['video'] = 'IMG_4444.m4v', ['label'] = 3, ['type'] = 'training'},
	[17] = {['video'] = 'IMG_4445.m4v', ['label'] = 3, ['type'] = 'training'},

	[18] = {['video'] = 'IMG_4446.m4v', ['label'] = 2, ['type'] = 'training'},
	[19] = {['video'] = 'IMG_4447.m4v', ['label'] = 2, ['type'] = 'training'},
	[20] = {['video'] = 'IMG_4448.m4v', ['label'] = 2, ['type'] = 'training'},
	[21] = {['video'] = 'IMG_4449.m4v', ['label'] = 2, ['type'] = 'training'},
	[22] = {['video'] = 'IMG_4450.m4v', ['label'] = 2, ['type'] = 'training'},
	[23] = {['video'] = 'IMG_4451.m4v', ['label'] = 2, ['type'] = 'training'},
	[24] = {['video'] = 'IMG_4452.m4v', ['label'] = 2, ['type'] = 'training'},

	[25] = {['video'] = 'IMG_4453.m4v', ['label'] = 1, ['type'] = 'training'},
	[26] = {['video'] = 'IMG_4454.m4v', ['label'] = 1, ['type'] = 'training'},
	[27] = {['video'] = 'IMG_4455.m4v', ['label'] = 1, ['type'] = 'training'},
	[28] = {['video'] = 'IMG_4456.m4v', ['label'] = 1, ['type'] = 'training'},
	[29] = {['video'] = 'IMG_4457.m4v', ['label'] = 1, ['type'] = 'training'},
	[30] = {['video'] = 'IMG_4458.m4v', ['label'] = 1, ['type'] = 'training'},
	[31] = {['video'] = 'IMG_4459.m4v', ['label'] = 1, ['type'] = 'training'},

	[32] = {['video'] = 'IMG_4462.m4v', ['label'] = 3, ['type'] = 'training'},
	[33] = {['video'] = 'IMG_4463.m4v', ['label'] = 3, ['type'] = 'training'},
	[34] = {['video'] = 'IMG_4464.m4v', ['label'] = 3, ['type'] = 'training'},
	[35] = {['video'] = 'IMG_4465.m4v', ['label'] = 3, ['type'] = 'training'},
	[36] = {['video'] = 'IMG_4466.m4v', ['label'] = 3, ['type'] = 'training'},
	[37] = {['video'] = 'IMG_4467.m4v', ['label'] = 3, ['type'] = 'training'},
	[38] = {['video'] = 'IMG_4468.m4v', ['label'] = 3, ['type'] = 'training'},
	[39] = {['video'] = 'IMG_4469.m4v', ['label'] = 3, ['type'] = 'training'},
	[40] = {['video'] = 'IMG_4470.m4v', ['label'] = 3, ['type'] = 'training'},
	[41] = {['video'] = 'IMG_4471.m4v', ['label'] = 3, ['type'] = 'training'},
	[42] = {['video'] = 'IMG_4472.m4v', ['label'] = 3, ['type'] = 'training'},
	[43] = {['video'] = 'IMG_4473.m4v', ['label'] = 3, ['type'] = 'training'},
	[44] = {['video'] = 'IMG_4474.m4v', ['label'] = 3, ['type'] = 'training'},
	[45] = {['video'] = 'IMG_4475.m4v', ['label'] = 3, ['type'] = 'training'},
	[46] = {['video'] = 'IMG_4476.m4v', ['label'] = 3, ['type'] = 'training'},
	[47] = {['video'] = 'IMG_4478.m4v', ['label'] = 3, ['type'] = 'training'},
	[48] = {['video'] = 'IMG_4479.m4v', ['label'] = 3, ['type'] = 'training'},
	[49] = {['video'] = 'IMG_4480.m4v', ['label'] = 3, ['type'] = 'training'},
	[50] = {['video'] = 'IMG_4481.m4v', ['label'] = 3, ['type'] = 'training'},
	[51] = {['video'] = 'IMG_4482.m4v', ['label'] = 3, ['type'] = 'training'},
	[52] = {['video'] = 'IMG_4483.m4v', ['label'] = 3, ['type'] = 'training'},
	[53] = {['video'] = 'IMG_4484.m4v', ['label'] = 3, ['type'] = 'training'},
	[54] = {['video'] = 'IMG_4485.m4v', ['label'] = 3, ['type'] = 'training'},
	[55] = {['video'] = 'IMG_4486.m4v', ['label'] = 3, ['type'] = 'training'},
	[56] = {['video'] = 'IMG_4487.m4v', ['label'] = 3, ['type'] = 'training'},
	[57] = {['video'] = 'IMG_4488.m4v', ['label'] = 3, ['type'] = 'training'},
	[58] = {['video'] = 'IMG_4489.m4v', ['label'] = 3, ['type'] = 'training'},
	[59] = {['video'] = 'IMG_4490.m4v', ['label'] = 3, ['type'] = 'training'},
	[60] = {['video'] = 'IMG_4491.m4v', ['label'] = 3, ['type'] = 'training'},
	[61] = {['video'] = 'IMG_4492.m4v', ['label'] = 3, ['type'] = 'training'},
	[62] = {['video'] = 'IMG_4493.m4v', ['label'] = 3, ['type'] = 'training'},

	[63] = {['video'] = 'IMG_4494.m4v', ['label'] = 2, ['type'] = 'training'},
	[64] = {['video'] = 'IMG_4495.m4v', ['label'] = 2, ['type'] = 'training'},
	[65] = {['video'] = 'IMG_4496.m4v', ['label'] = 2, ['type'] = 'training'},
	[66] = {['video'] = 'IMG_4497.m4v', ['label'] = 2, ['type'] = 'training'},
	[67] = {['video'] = 'IMG_4498.m4v', ['label'] = 2, ['type'] = 'training'},
	[68] = {['video'] = 'IMG_4499.m4v', ['label'] = 2, ['type'] = 'training'},
	[69] = {['video'] = 'IMG_4500.m4v', ['label'] = 2, ['type'] = 'training'},
	[70] = {['video'] = 'IMG_4501.m4v', ['label'] = 2, ['type'] = 'training'},
	[71] = {['video'] = 'IMG_4502.m4v', ['label'] = 2, ['type'] = 'training'},
	[72] = {['video'] = 'IMG_4503.m4v', ['label'] = 2, ['type'] = 'training'},
	[73] = {['video'] = 'IMG_4504.m4v', ['label'] = 2, ['type'] = 'training'},
	[74] = {['video'] = 'IMG_4505.m4v', ['label'] = 2, ['type'] = 'training'},
	[75] = {['video'] = 'IMG_4506.m4v', ['label'] = 2, ['type'] = 'training'},
	[76] = {['video'] = 'IMG_4507.m4v', ['label'] = 2, ['type'] = 'training'},
	[77] = {['video'] = 'IMG_4508.m4v', ['label'] = 2, ['type'] = 'training'},
	[78] = {['video'] = 'IMG_4509.m4v', ['label'] = 2, ['type'] = 'training'},
	[79] = {['video'] = 'IMG_4510.m4v', ['label'] = 2, ['type'] = 'training'},
	[80] = {['video'] = 'IMG_4511.m4v', ['label'] = 2, ['type'] = 'training'},
	[81] = {['video'] = 'IMG_4512.m4v', ['label'] = 2, ['type'] = 'training'},
	[82] = {['video'] = 'IMG_4513.m4v', ['label'] = 2, ['type'] = 'training'},


	[83] = {['video'] = 'IMG_4514.m4v', ['label'] = 1, ['type'] = 'training'},
	[84] = {['video'] = 'IMG_4515.m4v', ['label'] = 1, ['type'] = 'training'},
	[85] = {['video'] = 'IMG_4516.m4v', ['label'] = 1, ['type'] = 'training'},
	[86] = {['video'] = 'IMG_4517.m4v', ['label'] = 1, ['type'] = 'training'},
	[87] = {['video'] = 'IMG_4518.m4v', ['label'] = 1, ['type'] = 'training'},
	[88] = {['video'] = 'IMG_4519.m4v', ['label'] = 1, ['type'] = 'training'},
	[89] = {['video'] = 'IMG_4520.m4v', ['label'] = 1, ['type'] = 'training'},
	[90] = {['video'] = 'IMG_4521.m4v', ['label'] = 1, ['type'] = 'training'},
	[91] = {['video'] = 'IMG_4522.m4v', ['label'] = 1, ['type'] = 'training'},
	[92] = {['video'] = 'IMG_4523.m4v', ['label'] = 1, ['type'] = 'training'},
	[93] = {['video'] = 'IMG_4524.m4v', ['label'] = 1, ['type'] = 'training'},
	[94] = {['video'] = 'IMG_4525.m4v', ['label'] = 1, ['type'] = 'training'},
	[95] = {['video'] = 'IMG_4526.m4v', ['label'] = 1, ['type'] = 'training'},
	[96] = {['video'] = 'IMG_4527.m4v', ['label'] = 1, ['type'] = 'training'},
	[97] = {['video'] = 'IMG_4528.m4v', ['label'] = 1, ['type'] = 'training'},
	[98] = {['video'] = 'IMG_4529.m4v', ['label'] = 1, ['type'] = 'training'},
	[99] = {['video'] = 'IMG_4530.m4v', ['label'] = 1, ['type'] = 'training'},
	[100] = {['video'] = 'IMG_4531.m4v', ['label'] = 1, ['type'] = 'training'},
	[101] = {['video'] = 'IMG_4532.m4v', ['label'] = 1, ['type'] = 'training'},
	[102] = {['video'] = 'IMG_4533.m4v', ['label'] = 1, ['type'] = 'training'},
	[103] = {['video'] = 'IMG_4534.m4v', ['label'] = 1, ['type'] = 'training'},

	[104] = {['video'] = 'IMG_4537.m4v', ['label'] = 1, ['type'] = 'validation'},
	[105] = {['video'] = 'IMG_4538.m4v', ['label'] = 1, ['type'] = 'validation'},
	[106] = {['video'] = 'IMG_4539.m4v', ['label'] = 1, ['type'] = 'validation'},
	[107] = {['video'] = 'IMG_4540.m4v', ['label'] = 1, ['type'] = 'validation'},
	[108] = {['video'] = 'IMG_4541.m4v', ['label'] = 1, ['type'] = 'validation'},
	[109] = {['video'] = 'IMG_4542.m4v', ['label'] = 1, ['type'] = 'validation'},

	[110] = {['video'] = 'IMG_4543.m4v', ['label'] = 3, ['type'] = 'validation'},
	[111] = {['video'] = 'IMG_4544.m4v', ['label'] = 3, ['type'] = 'validation'},
	[112] = {['video'] = 'IMG_4545.m4v', ['label'] = 3, ['type'] = 'validation'},
	[113] = {['video'] = 'IMG_4546.m4v', ['label'] = 3, ['type'] = 'validation'},
	[114] = {['video'] = 'IMG_4547.m4v', ['label'] = 3, ['type'] = 'validation'},


	[118] = {['video'] = 'IMG_4550.m4v', ['label'] = 2, ['type'] = 'validation'},
	[119] = {['video'] = 'IMG_4551.m4v', ['label'] = 2, ['type'] = 'validation'},
	[120] = {['video'] = 'IMG_4552.m4v', ['label'] = 2, ['type'] = 'validation'},
	[121] = {['video'] = 'IMG_4553.m4v', ['label'] = 2, ['type'] = 'validation'},
	[122] = {['video'] = 'IMG_4554.m4v', ['label'] = 2, ['type'] = 'validation'},
	[123] = {['video'] = 'IMG_4555.m4v', ['label'] = 2, ['type'] = 'validation'},
	[124] = {['video'] = 'IMG_4556.m4v', ['label'] = 2, ['type'] = 'validation'},
	[125] = {['video'] = 'IMG_4557.m4v', ['label'] = 2, ['type'] = 'validation'},
	[126] = {['video'] = 'IMG_4558.m4v', ['label'] = 2, ['type'] = 'validation'},
	[127] = {['video'] = 'IMG_4559.m4v', ['label'] = 2, ['type'] = 'validation'},
	[128] = {['video'] = 'IMG_4560.m4v', ['label'] = 2, ['type'] = 'validation'},

	[129] = {['video'] = 'IMG_4561.m4v', ['label'] = 3, ['type'] = 'validation'},
	[130] = {['video'] = 'IMG_4562.m4v', ['label'] = 3, ['type'] = 'validation'},
	[131] = {['video'] = 'IMG_4563.m4v', ['label'] = 3, ['type'] = 'validation'},
	[132] = {['video'] = 'IMG_4564.m4v', ['label'] = 3, ['type'] = 'validation'},
	[133] = {['video'] = 'IMG_4565.m4v', ['label'] = 3, ['type'] = 'validation'},
	[134] = {['video'] = 'IMG_4566.m4v', ['label'] = 3, ['type'] = 'validation'},
	[135] = {['video'] = 'IMG_4567.m4v', ['label'] = 3, ['type'] = 'validation'},

	[136] = {['video'] = 'IMG_4568.m4v', ['label'] = 1, ['type'] = 'validation'},
	[137] = {['video'] = 'IMG_4569.m4v', ['label'] = 1, ['type'] = 'validation'},
	[138] = {['video'] = 'IMG_4570.m4v', ['label'] = 1, ['type'] = 'validation'},
	[139] = {['video'] = 'IMG_4571.m4v', ['label'] = 1, ['type'] = 'validation'},
	[140] = {['video'] = 'IMG_4572.m4v', ['label'] = 1, ['type'] = 'validation'},
	[141] = {['video'] = 'IMG_4573.m4v', ['label'] = 1, ['type'] = 'validation'},
}

op = xlua.OptionParser('process_videos.lua [options]')
op:option{'-d', '--dir', action='store', dest='dir', help='directory to load videos', req=true}
op:option{'-e', '--ext', action='store', dest='ext', help='only load files of this extension', default='png'}
op:option{'-f', '--frames', action='store', dest='frames', help='controls how frames must be skipped', default=15}
op:option{'-o', '--out', action='store', dest='output', help='folder to output files', req=true}
op:option{'-b', '--batch_length', action='store',dest='batch_length', help='number of frames per batch', default=150}
opt = op:parse()

opt.batch_length = tonumber(opt.batch_length)

PREPRO_P = 0.003
HEIGHT = 427
WIDTH = 240

for_preprocessing = {}

--------------------------------------------------------------------------------
-- PREPARATION
--------------------------------------------------------------------------------
os.execute("rm " .. opt.output .. "/*")
lfs.mkdir(opt.output)
TMP_DIR = opt.dir .. "/tmpFrameFolder"

--------------------------------------------------------------------------------
-- PARSE ALL VIDEOS
--------------------------------------------------------------------------------
for videoNumber, video in ipairs(videos) do
	io.write(string.format('processing sample %4d of %d: ', videoNumber, #videos))
	io.flush()
	-- create folder where all frames will be saved in
	os.execute("rm -rf " .. TMP_DIR)
	lfs.mkdir(TMP_DIR)

	-- extracts frames from video
	os.execute("ffmpeg -loglevel panic -i " .. opt.dir .. "/" .. video['video'] .. " -r " .. opt.frames .. " -vf scale=240:-1 " .. TMP_DIR .. "/frame%d." .. opt.ext)

	-- produce output
	local tensor = process_directory(TMP_DIR, opt.ext, opt.batch_length)
	local res
	if tensor ~= nil then
		res = {}
		res['data'] = tensor
		res['label'] = video['label']

		local num_process = torch.random() % 4
		while num_process > 0 do
			local i = (torch.random() % tensor:size(1)) + 1
			table.insert(for_preprocessing, tensor:sub(i,i))
			num_process = num_process - 1
		end

		-- save result in torch file
		torch.save(name_for_video(videoNumber), res)
	end
end

--------------------------------------------------------------------------------
-- CALCULATE PREPROCESSING
--------------------------------------------------------------------------------
for_preprocessing = torch.cat(for_preprocessing, 1)

mean = torch.mean(for_preprocessing, 1):squeeze()
std = torch.std(for_preprocessing, 1):squeeze()
std_inv = std:pow(-1)

torch.save(path.join(opt.output, 'preprocessing.t7'), {
	mean = mean,
	std = std
})

--------------------------------------------------------------------------------
-- APPLY TRANSFORM
--------------------------------------------------------------------------------
for videoNumber = 1, #videos do
	if file_exists(name_for_video(videoNumber)) then
		video = torch.load(name_for_video(videoNumber))
		for i = 1, video['data']:size(1) do
			video['data'][i]:add(-1, mean)
			video['data'][i]:cmul(std_inv)
		end
		torch.save(name_for_video(videoNumber), video)
	end
end

-- run preprocessing
-- samples = {}
-- print('sampling from ' .. #for_preprocessing .. ' images')
-- while #samples < PREPRO_SAMPLES do
-- 	local x = torch.random() % (HEIGHT - PATCH_SIZE + 1) + 1
-- 	local y = torch.random() % (WIDTH - PATCH_SIZE + 1) + 1
-- 	local i = torch.random() % (#for_preprocessing) + 1
-- 	table.insert(samples, for_preprocessing[i]:sub(1,1,x,x+PATCH_SIZE-1,y,y+PATCH_SIZE-1):reshape(1, PATCH_SIZE*PATCH_SIZE))
-- end
--
-- samples = torch.cat(samples, 1)
--
-- torch.save('samples.t7', samples)


-- zca = ZCA()
-- zca:fit(samples)
-- print('preprocessing data')
-- for videoNumber, video in ipairs(videos) do
-- 	local video = torch.load(name_for_video(videoNumber))
-- 	local data = video['data']
-- 	for frame_idx = 1, data:size(1) do
-- 		local frame = data[frame_idx]
-- 		for x = 1, HEIGHT, PATCH_SIZE do
-- 			for y = 1, WIDTH, PATCH_SIZE do
--
-- 				if x + PATCH_SIZE > HEIGHT then
-- 					x = HEIGHT - PATCH_SIZE + 1
-- 				end
-- 				if y + PATCH_SIZE > WIDTH then
-- 					y = WIDTH - PATCH_SIZE + 1
-- 				end
--
-- 				local patch = frame:sub(x,x+PATCH_SIZE-1,y,y+PATCH_SIZE-1)
-- 				local transformed = zca:transform(patch:reshape(1,PATCH_SIZE*PATCH_SIZE))
-- 				-- local transformed = patch
-- 				frame:sub(x,x+PATCH_SIZE-1,y,y+PATCH_SIZE-1):copy(transformed:reshape(PATCH_SIZE, PATCH_SIZE))
-- 			end
-- 		end
-- 		data[frame_idx]:copy(frame)
-- 	end
-- 	video.data:copy(data)
-- 	torch.save(name_for_video(videoNumber), video)
-- end

-- remove this folder, we do not need it anymore
os.execute("rm -rf " .. TMP_DIR)
