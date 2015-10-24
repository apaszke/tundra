exec = require('child_process').exec
fs = require 'fs'
express = require 'express'
bodyParser = require 'body-parser'

Filename = "video.mp4"
FramesDir = "frames"
FramesExt = "png"
Fps = 15

processVideo = (cb) ->
    exec "rm -fr #{FramesDir} && mkdir -p #{FramesDir}", (err) ->
        if err
            cb "Error during preparations"
            return
        cmd = "ffmpeg -loglevel panic -i #{Filename} -r #{Fps} -vf scale=240:-1 #{FramesDir}/frame%d.#{FramesExt}"
        exec cmd, (error, stdout, stderr) ->
            if err
                cb "Error with ffmpeg"
                return
            # Here goes lua predict
            cmd = "echo \'prediction goes here\'"
            exec cmd, (error, stdout, stderr) ->
                if err
                    cb "Error with predicting"
                    return
                cb null, stdout

app = express()
app.use bodyParser.raw()

app.use (req, res, next) =>
  data = new Buffer ''
  req.on 'data', (chunk) =>
      data = Buffer.concat [data, chunk]
  req.on 'end', =>
    req.rawBody = data
    fs.writeFile Filename, data
    processVideo (err, prediction) ->
        if err
            console.error err
        else
            res.send prediction

server = app.listen 3000
