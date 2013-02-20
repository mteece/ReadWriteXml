# Introduction #

Just a sandbox for messing around with IOS and services for rapid prototyping. Sometime you just need a service around whispering sweet JSON/SML responses.

## Quick Start ##

Get off the ground fast.

### Virtual Env ###

Make your virtualenv.

`$ mkvirtualenv ReadWriteXml`  
`$ sudo pip install flask`  

Need to make requirement file still.

`$ WORKON ReadWriteXml`  
`$ cd Web/`  
`$ python index.py`  

### Browser ###

Chrome and the Postman plug in help `http://127.0.0.1:5000/`.

### Paths ###

Based on `http://127.0.0.1:5000/' there are more routes in `index.py`.

GET /  
Welcome

GET /articles  
List of /articles

GET /articles/123  
You are reading 123

## XML ##
POST /xml  
http://127.0.0.1:5000/xml

## Docs ##
http://flask.pocoo.org/docs/quickstart/#a-minimal-application
