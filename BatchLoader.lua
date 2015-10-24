require 'torch'

math.randomseed( os.time() )

-- shuffles table in place
local function shuffleTable( t )
    local rand = math.random
    assert( t, "shuffleTable() expected a table, got nil" )
    local iterations = #t
    local j

    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

local BatchLoader = {}
BatchLoader.__index = BatchLoader

-- inits batch file loader
function BatchLoader.create( dir )
	local self = {}
	setmetatable(self, BatchLoader)
	self.dir = dir
	self.ext = 't7'

	-- load sets
	self:load_training_sets()
	self:load_validation_sets()
	print(string.format('found %d training and %d validation batches', self:num_training_batches(), self:num_validation_batches()))
	return self
end

-- loads files which are signed as training batches
function BatchLoader:load_training_sets()
	self.trainingSets = {}
	self.currentTrainingSet = 1

	for file in paths.files(self.dir) do
		if file:find(self.ext .. '$') and file:find('training') then
			table.insert(self.trainingSets, paths.concat(self.dir, file))
		end
	end
end

-- returns number of training batches
function BatchLoader:num_training_batches()
	return #self.trainingSets
end

-- returns next training batch
-- when next is nil shuffles array and starts from first element
function BatchLoader:next_training_batch()
	if self.trainingSets == nil then
		self:load_training_sets()
	end

	-- we reached the end of training sets
	if #self.trainingSets < self.currentTrainingSet then
		shuffleTable(self.trainingSets)
		self.currentTrainingSet = 1
	end

	data = torch.load(self.trainingSets[self.currentTrainingSet])
	self.currentTrainingSet = self.currentTrainingSet + 1
	return data['data'], data['label']
end

-- loads files which are signed as validation batches
function BatchLoader:load_validation_sets()
	self.validationSets = {}
	self.currentValidationSet = 1

	for file in paths.files(self.dir) do
		if file:find(self.ext .. '$') and file:find('validation') then
			table.insert(self.validationSets, paths.concat(self.dir, file))
		end
	end
end

-- returns number of validation batches
function BatchLoader:num_validation_batches()
	return #self.validationSets
end

-- returns next validation batch
-- when next is nil shuffles array and starts from first element
function BatchLoader:next_validation_batch()
	if self.validationSets == nil then
		self:load_validation_sets()
	end

	-- we reached the end of validations sets
	if #self.validationSets < self.currentValidationSet then
		shuffleTable(self.validationSets)
		self.currentValidationSet = 1
	end

	data = torch.load(self.validationSets[self.currentValidationSet])
	self.currentValidationSet = self.currentValidationSet + 1
	return data['data'], data['label']
end

return BatchLoader
