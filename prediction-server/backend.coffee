exec = require('child_process').exec
fs = require 'fs'
express = require 'express'
bodyParser = require 'body-parser'
SocketIo = require 'socket.io'
siofu = require "socketio-file-upload"

ServerDir = "prediction-server"
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
            cmd = "th predict.lua -video_dir #{ServerDir}/#{FramesDir} -model #{ServerDir}/cp.t7"
            exec cmd, {cwd: '..'}, (error, stdout, stderr) ->
                if err
                    cb "Error with predicting"
                    return
                console.log stderr
                cb null, stdout

app = express()
    .use(siofu.router)
    .listen 3001

io = new SocketIo
io.listen app

io.on "connection", (socket) ->
    uploader = new siofu()
    uploader.dir = __dirname
    uploader.listen socket
    uploader.on 'saved', ->
        console.log "saved"
        processVideo (err, prediction) ->
            if err
                console.error err
            else
                res.send prediction
