http = require('http')
util = require('util')
url = require('url')
nodeStatic = require('node-static')

ApplicationServer = (config)->	
	_self = @
	_httpServer = new HttpServer(config)

module.exports.Application = ApplicationServer