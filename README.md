Roomular
========

A web app for finding nearby classes (or study spaces) at the University of Waterloo.

## Getting started
1. Install [`node`](http://nodejs.org/) if you don't already have it installed.
2. `git clone git@github.com:christhomson/roomular.git`
3. `cd roomular`
4. `npm install`
5. `cp config/local.json.sample config/local.json`
6. Edit `config/local.json` to include your [UW API key](http://api.uwaterloo.ca/#!/keygen) and [Mixpanel](http://mixpanel.com) token.
7. `coffee app.coffee` (or `nodemon app.coffee` if you use [`nodemon`](https://github.com/remy/nodemon)).
