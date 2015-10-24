require 'torch'
require 'lfs'
require 'image'
require 'xlua'

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
	[7] = {['video'] = 'IMG_4434.m4v', ['label'] = 2, ['type'] = 'validation'},
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
	[31] = {['video'] = 'IMG_4459.m4v', ['label'] = 1, ['type'] = 'training'}
}

op = xlua.OptionParser('process_videos.lua [options]')
op:option{'-d', '--dir', action='store', dest='dir', help='directory to load videos', req=true}
op:option{'-e', '--ext', action='store', dest='ext', help='only load files of this extension', default='png'}
op:option{'-f', '--frames', action='store', dest='frames', help='controls how frames must be skipped', default=15}
op:option{'-o', '--out', action='store', dest='output', help='folder to output files', req=true}
op:option{'-l', '--length', action='store',dest='framesLength', help='number of frames for file', default=150}
op:option{'-b', '--batch_length', action='store',dest='batchLength', help='number of frames per batch', default=150}
opt = op:parse()
op:summarize()

opt.framesLength = tonumber(opt.framesLength)
opt.batchLength = tonumber(opt.batchLength)

-- opt.dir = '/Users/VirrageS/Desktop'
-- opt.ext = 'png'
-- opt.frames = 30
-- opt.output = '/Users/VirrageS/Desktop/torch-files'
-- opt.framesLenght = 150


-- COMPUTE

-- remove and make new folder with compressed tensors
os.execute("rm " .. opt.output .. "/*")
lfs.mkdir(opt.output)

tmp_dir = opt.dir .. "/tmpFrameFolder"
for videoNumber, video in ipairs(videos) do
	-- create folder where all frames will be saved in
	os.execute("rm -rf " .. tmp_dir)
	lfs.mkdir(tmp_dir)

	-- extracts frames from video
	os.execute("ffmpeg -loglevel panic -i " .. opt.dir .. "/" .. video['video'] .. " -r " .. opt.frames .. " -vf scale=240:-1 " .. tmp_dir .. "/frame%d." .. opt.ext)

	-- store all files
	files = {}

	-- go over all files in directory. We use an iterator, paths.files().
	for file in paths.files(tmp_dir) do
		-- We only load files that match the extension
		if file:find(opt.ext .. '$') then
			-- and insert the ones we care about in our table
			table.insert(files, paths.concat(tmp_dir, file))
		end
	end

	-- check files
	if #files == 0 then
		error('Given directory does not contain any files of type: ' .. opt.ext)
	end

	-- sort files by frame number
	table.sort(files, function (a,b) return tonumber(string.match(a,"%d+")) < tonumber(string.match(b,"%d+")) end)

	-- show only odd frames (skip one)
	tmp_files = {}
	for i,file in ipairs(files) do
		if i <= opt.batchLength then
			table.insert(tmp_files, file)
		end
	end
	print(#tmp_files)
	if #tmp_files < opt.batchLength then
		print('Video is too short!')
		goto continue
	end
	files = tmp_files

	-- load all images
	images = {}
	for i,file in ipairs(files) do
		-- load each image
		table.insert(images, image.load(file))
	end

	-- conver to grey images
	-- grey_images = {}
	big_tensor = torch.Tensor(opt.batchLength, 427, 240)
	for i,cur_image in ipairs(images) do
		-- table.insert(grey_images, image.rgb2y(cur_image))
		big_tensor[i]:copy(image.rgb2y(cur_image))
	end

	-- print(grey_images)
	-- produce output
	res = {}
	res['data'] = big_tensor
	res['label'] = video['label']

	-- save result in torch file
	torch.save(opt.output .. "/" .. video['type'] .. "_" .. videoNumber .. ".t7", res)
	::continue::
end

-- remove this folder, we do not need it anymore
os.execute("rm -rf " .. tmp_dir)
