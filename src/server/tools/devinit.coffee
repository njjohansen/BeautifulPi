#
# This file is part of the Spludo Framework.
# Copyright (c) 2009-2010 DracoBlue, http://dracoblue.net/
#
# Licensed under the terms of MIT License. For the full copyright and license
# information, please see the LICENSE file in the root folder.
#

child_process = require('child_process')
fs = require("fs")
util = require("util")

dev_server = {
	process: null,
	files: [],
	restarting: false,
	"restart": ()->
		this.restarting = true
		util.debug('DEVSERVER: Stopping server for restart')
		this.process.kill()
	,"start": ()->
		self = this
		util.debug('DEVSERVER: Starting server')
		self.watchFiles()
		
		util.debug('DEVSERVER: spawning process')
		this.process = child_process.spawn(process.argv[0], ['init.js'])
		util.debug('DEVSERVER: process spawned')

		this.process.stdout.addListener('data', (data)->
			process.stdout.write(data)
		)

		this.process.stderr.addListener('data', (data)->
			util.print(data)
		)

		this.process.addListener('exit', (code)->
			util.debug('DEVSERVER: Child process exited: ' + code)
			this.process = null
			if (self.restarting)
				self.restarting = true
				self.unwatchFiles()
				self.start()
		)
	,"watchFiles": ()->
		self = this
		child_process.exec('find . | grep "\.js$"', (error, stdout, stderr)->
			files = stdout.trim().split("\n")
			files.forEach( (file)->
				self.files.push(file)
				fs.watchFile(file, {interval : 500}, (curr, prev)->
					if (curr.mtime.valueOf() != prev.mtime.valueOf() || curr.ctime.valueOf() != prev.ctime.valueOf())
						util.debug('DEVSERVER: Restarting because of changed file at ' + file)
						dev_server.restart()
				)
			)
		)
	,"unwatchFiles": ()->
		this.files.forEach( (file)->
			fs.unwatchFile(file)
		)
		this.files = []
}


dev_server.start()




