HttpServer = (options) ->
	self = @
	@settings = { 
		port: options.httpServerPort
	}
	@httpServer = null

	init = ->
		self.httpServer = self.createHTTPServer()
		self.httpServer.listen(self.settings.port)
		util.log('Http server started listening on PORT ' + self.settings.port)
		self.httpServer
		
	init()
	
HttpServer.prototype.createHTTPServer = ->
	self = this
	server = http.createServer( (request, response) ->
		file = new nodeStatic.Server('build/client/public/', {cache: false})
		request.addListener('end', ->
			location = url.parse(request.url, true)
			params = location.query || request.headers
			# util.log('Location pathname: ' + location.pathname)
			# for head,val of location.query
			#	console.log('Header: ' + head + ' Value: ' + val )

			if location.pathname == '/config.json' and request.method == "GET"
				# -------- DYNAMIC RESPONSE (json config file)------
				response.writeHead(200, {'Content-Type': 'application/x-javascript'})
				jsonString = JSON.stringify({
					serverPort: ServerConfig.serverPort
					webServiceUrl: ServerConfig.webServiceUrl
					})
				response.write(jsonString)
				response.end()
			else if location.pathname == '/stat' and request.method == 'GET'
				# --------- DYNAMIC RESPONSE report new visitor to all listening clients ------ 
				response.writeHead(200, {'Content-Type': 'text/plain'})
				response.write("ok")
				response.end()							
			else
				# ----- Static files -----
				file.serve(request, response)
		)
	)
	server