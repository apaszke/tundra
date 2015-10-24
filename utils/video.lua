require 'image'

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function name_for_video(videoNumber)
	return opt.output .. "/" .. videos[videoNumber]['type'] .. "_" .. videoNumber .. ".t7"
end

function find_files(dir, ext)
	files = {}

	-- go over all files in directory. We use an iterator, paths.files().
	for file in paths.files(dir) do
		-- We only load files that match the extension
		if file:find(ext .. '$') then
			-- and insert the ones we care about in our table
			table.insert(files, paths.concat(dir, file))
		end
	end

	-- check files
	if #files == 0 then
		error('Given directory does not contain any files of type: ' .. ext)
	end

	return files
end

function load_y_images(files)
  images = {}
	for i,file in ipairs(files) do
		-- load each image
		table.insert(images, image.rgb2y(image.load(file)))
	end
  return images
end

function slice_list(list, max_length)
	slice = {}
	for i,item in ipairs(list) do
		if i <= max_length then
			table.insert(slice, item)
		end
	end
	return slice
end

function process_directory(dir, ext, batch_length, quiet)
  quiet = quiet or false
	-- store all files
	files = find_files(dir, ext)

	-- sort files by frame number
	table.sort(files, function (a,b)
		return tonumber(string.match(a,"%d+")) < tonumber(string.match(b,"%d+"))
	end)

	-- use only first batch_length files
  if batch_length > -1 then
  	used_files = slice_list(files, batch_length)
  else
    used_files = files
  end

  if not quiet then
  	if #used_files < batch_length then
  		print(sys.COLORS.red .. string.format('%d/%d',#used_files,batch_length))
  		return nil
  	else
  		print(sys.COLORS.green .. string.format('%d/%d',#used_files,#files))
  	end
  end

	-- load all images
	local images = load_y_images(used_files)

	-- pack all images into one tensor
	-- randomly select frames for preprocessing
  local length
  if batch_length > -1 then
    length = batch_length
  else
    length = #images
  end
	big_tensor = torch.Tensor(length, images[1]:size(2), images[1]:size(3))
	for i,image in ipairs(images) do
		big_tensor[i]:copy(image)
	end

	return big_tensor
end
