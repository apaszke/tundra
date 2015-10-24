require 'torch'

local BatchLoader = {}
BatchLoader.__index = BatchLoader

function BatchLoader.create(dir)
	local self = {}
	setmetatable(self, BatchLoader)
	self.dir = dir
	self.ext = 't7'

	-- load sets
	self:load_training_sets()
	self:load_validation_sets()
	return self
end

function BatchLoader:load_training_sets()
	self.trainingSets = {}
	self.currentTrainingSet = 1

	for file in paths.files(self.dir) do
		if file:find(self.ext .. '$') and file:find('training') then
			table.insert(self.trainingSets, torch.load(paths.concat(self.dir, file)))
		end
	end
end

function BatchLoader:num_training_batches()
	return #self.trainingSets
end

function BatchLoader:next_training_batch()
	if self.trainingSets == nil then
		self:load_training_sets()
	end

	-- we reached the end of training sets
	if #self.trainingSets < self.currentTrainingSet then
		self.currentTrainingSet = 1
	end

	data = self.trainingSets[self.currentTrainingSet]
	self.currentTrainingSet = self.currentTrainingSet + 1
	return data['data'], data['label']
end

function BatchLoader:load_validation_sets()
	self.validationSets = {}
	self.currentValidationSet = 1

	for file in paths.files(self.dir) do
		if file:find(self.ext .. '$') and file:find('validation') then
			table.insert(self.validationSets, torch.load(paths.concat(self.dir, file)))
		end
	end
end

function BatchLoader:num_validation_batches()
	return #self.validationSets
end

function BatchLoader:next_validation_batch()
	if self.validationSets == nil then
		self:load_validation_sets()
	end

	-- we reached the end of validations sets
	if #self.validationSets < self.currentValidationSet then
		self.currentValidationSet = 1
	end

	data = self.validationSets[self.currentValidationSet]
	self.currentValidationSet = self.currentValidationSet + 1
	return data['data'], data['label']
end

return BatchLoader
