#require.paths.unshift(__dirname + "/vendor")

process.addListener('uncaughtException', (err, stack)->
	console.log('---------------------')
	console.log('Exception: ' + err)
	console.log(err.stack)
	console.log('---------------------')
)

ApplicationServer = require('./BeautifulPi').Application

new ApplicationServer({httpServerPort: 8001})
