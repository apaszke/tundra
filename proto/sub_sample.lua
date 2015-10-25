cnn = nn.Sequential()

cnn:add( nn.SpatialConvolution(1, 20, 3, 3, 2, 2) )
cnn:add( nn.ReLU() )
cnn:add( nn.SpatialMaxPooling(2, 2) )
cnn:add( nn.Dropout(0.25) )

cnn:add( nn.SpatialConvolution(20, 15, 3, 3, 2, 2) )
cnn:add( nn.ReLU() )
cnn:add( nn.SpatialMaxPooling(2, 2) )
cnn:add( nn.Dropout(0.25) )

-- fc
cnn:add( nn.SpatialConvolution(15, 600, 14, 26) )
cnn:add( nn.Dropout(0.3) )
cnn:add( nn.ReLU() )

-- output
cnn:add( nn.View(1, 600) )
