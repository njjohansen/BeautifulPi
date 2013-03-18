fs     = require 'fs'
{exec} = require 'child_process'
util   = require 'util'

SrcSharedDir		= 'cs/shared'
SrcServerDir		= 'cs/server'
SrcServerTestDir	= 'cs/server/test'
SrcClientDir		= 'cs/client'

TargetServerName	= 'server'
TargetServerTestName= 'serverTest'
TargetClientName	= 'client'

TargetServerDir		= 'js'
TargetClientDir		= 'js/public/js'

SharedFiles = [
]

ServerFiles = [
	'Application'
	'HttpServer'
]

ClientFiles = [
	'Pi'
]

ServerTestFiles = [
]

TargetServerCoffeeFile = "#{SrcServerDir}/out/#{TargetServerName}.coffee"
TargetClientCoffeeFile = "#{SrcClientDir}/out/#{TargetClientName}.coffee"
TargetServerTestCoffeeFile = "#{SrcServerDir}/out/#{TargetServerTestName}.coffee"

ServerOpts = "--bare --output #{TargetServerDir} --compile #{TargetServerCoffeeFile}"
ClientOpts = "--bare --output #{TargetClientDir} --compile #{TargetClientCoffeeFile}"
ServerTestOpts = "--bare --output #{TargetServerDir} --compile #{TargetServerTestCoffeeFile}"

task 'build', 'Build Master Coffee Script files and compile to JavaScript', ->
	serverContent = new Array()
	clientContent = new Array()
	serverTestContent = new Array()
	serverFileCount = {count: SharedFiles.length + ServerFiles.length}
	clientFileCount = {count: SharedFiles.length + ClientFiles.length}
	serverTestFileCount = {count: ServerTestFiles.length}
	
	readCoffeeFiles = (srcDir, fileArray, arrayOffset, contentArray, listName, totalFileCount, targetCoffeeFile, coffeeOptions)->
		
		writeCoffeeFileAndCompile = (contentArray, targetCoffeeFile, coffeeOptions)->
			fs.writeFile targetCoffeeFile
				, contentArray.join('\n\n')
				, 'utf8'
				, (err) ->
					util.log "#{err}\n" if err
					exec "coffee #{coffeeOptions}", (err, stdout, stderr) ->
						util.log err if err
						util.log "Compiled #{targetCoffeeFile}."
						#remove the master coffee file
						#fs.unlink targetCoffeeFile, (err) -> util.log err if err

		
		util.log "Appending #{fileArray.length} files to: #{listName}"
		for file, index in fileArray then do (file, index) ->
			fs.readFile("#{srcDir}/#{file}.coffee"
					, 'utf8'
					, (err, fileContent) ->
				util.log err if err
				contentArray[index+arrayOffset] = fileContent
				util.log("[#{index + arrayOffset + 1}] #{file}.coffee")
				if(--totalFileCount.count is 0)
					writeCoffeeFileAndCompile(contentArray, targetCoffeeFile, coffeeOptions) 
			)

	# read coffee files
	# server files
	readCoffeeFiles(SrcSharedDir, SharedFiles, 0, serverContent, "server-library", serverFileCount, TargetServerCoffeeFile, ServerOpts)
	readCoffeeFiles(SrcServerDir, ServerFiles, SharedFiles.length, serverContent, "server-library", serverFileCount, TargetServerCoffeeFile, ServerOpts)	
	#client files
	readCoffeeFiles(SrcSharedDir, SharedFiles, 0, clientContent, "client-library", clientFileCount, TargetClientCoffeeFile, ClientOpts)
	readCoffeeFiles(SrcClientDir, ClientFiles, SharedFiles.length, clientContent, "client-library", clientFileCount, TargetClientCoffeeFile, ClientOpts)
	# server test	
	readCoffeeFiles(SrcServerTestDir, ServerTestFiles, 0, serverTestContent, "server-test-library", serverTestFileCount, TargetServerTestCoffeeFile, ServerTestOpts)	
		

task 'watch', 'Watch  source files and build changes', ->
	util.log "Watching for changes in project..."
	
	registerCoffeeFiles = (dir, files)->
		for file in files then do (file) ->
			fs.watchFile "#{dir}/#{file}.coffee", (curr, prev) ->
				if +curr.mtime isnt +prev.mtime
					util.log "Saw change in #{dir}/#{file}.coffee\n"
					invoke 'build'
	
	registerCoffeeFiles(SrcServerDir, ServerFiles)
	registerCoffeeFiles(SrcClientDir, ClientFiles)
	registerCoffeeFiles(SrcSharedDir, SharedFiles)	
	registerCoffeeFiles(SrcServerTestDir, ServerTestFiles)