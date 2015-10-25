# tundra
*Identification of people on videos based on their walking style
using convolutional and recurrent neural networks.*

# To do

* Add a section about using your own neural network with *tundra*.

# Installation
We use a lot of technologies, so you've got to do a lot of stuff.

You can do it step by step with this little tutorial or just scroll down
to see a longer code snippet that you can just copypaste into your terminal.

## Get required software first!

* Ruby and  Ruby on Rails (Frontend Server)
    * You will have to run `bundle install` in `front-server` directory
* Node.js (Backend Prediction Server)
    * You will have to run `npm install` in `prediction-server` directory
* Torch7 (Neural Networks)
    * [Torch7 installation guide](http://torch.ch/docs/getting-started.html#installing-torch)
* ffmpeg (Data Preprocessing)
    * [You download it here](http://ffmpeg.org/download.html)

## Copypaste script for a quick start
``` bash
git clone https://github.com/apaszke/tundra
cd tundra/front-server
bundle install
cd ../prediction-server
npm install
```

# How to launch:

### Run Frontend Server:
``` bash
./run-frontend-server.sh
```
### Run Prediction Server
``` bash
./run-prediction-server.sh
```
# How to use
Now you can open your browser at `localhost:1337` and test the neural network.

# Trivia

### When it started
We've done a prototype of tundra-force
### Inspiration
People can easily recognize the walking style of their friends.
Let's see if we can teach a computer to identify walking people on videos.

### What it does
It identifies people on videos based on their walking style.

### How we built it
We build a neural network in torch and trained in on Amazon Web Service
because we needed a lot of computing power.
Additionally, we've made a website client in Ruby on Rails
and a back-end server in Node.js which runs a trained neural network.
When this neural network receives a video
it returns the probabilities for every person it knows
that the person is walking in the uploaded video.

### Was it easy to create a neural network good enough for pitching at AGHacks 2015?

!["Yes it was"](http://i.imgur.com/bSiNEq6.gif)

### What's next for tundra-force dev team
We're going to...

![Dade is shouting HACK THE PLANET!](https://media.giphy.com/media/14kdiJUblbWBXy/giphy.gif)

### Why 'tundra-force'
Well, the *tundra* word just sounds awesome, doesn't it?

![Awesomeness"](http://ichef-1.bbci.co.uk/news/660/media/images/76411000/jpg/_76411495_452256364.jpg)
