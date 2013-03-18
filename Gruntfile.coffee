module.exports = (grunt)->
	# Project configuration.
	grunt.initConfig({
		pkg: grunt.file.readJSON('package.json'),
		coffee: {
			compile: {
				files: {
					'build/server/init.js': 'src/server/tools/init.coffee'
					'build/server/devinit.js': 'src/server/tools/devinit.coffee'
					'build/server/<%= pkg.name %>.js': ['src/server/*.coffee'] # compile and concat into single file
					'build/client/public/js/<%= pkg.name %>.js': ['src/client/*.coffee'] # compile and concat into single file
				},
				options: {
					bare: true
				}
			}
		},
		uglify: {
			serverBuild: {
				options: {banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'},
				files: { 'build/server/<%= pkg.name %>.min.js': ['build/server/<%= pkg.name %>.js']}
			},
			clientBuild: {
				options: {banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'},
				files: {'build/client/public/js/<%= pkg.name %>.min.js': [ 'build/client/public/js/<%= pkg.name %>.js']}
			}
		},
		copy: {
			main: {
				files: [
					# {src: ['src/client/**'], dest: 'build/client/'},# includes files in path
					{expand: true, cwd: 'src/client/public/', src: ['**'], dest: 'build/client/public/'} # makes all src relative to cwd
					# {expand: true, flatten: true, src: ['src/client/**'], dest: 'build/client', filter: 'isFile'} # flattens results to a single level	
					# {src: ['path/**'], dest: 'dest/'} # includes files in path and its subdirs
				]
			}
		}
	})

	#Load the plugins
	grunt.loadNpmTasks('grunt-contrib-coffee')	
	grunt.loadNpmTasks('grunt-contrib-uglify')
	grunt.loadNpmTasks('grunt-contrib-copy')	

	#Default task(s).
	grunt.registerTask('default', ['coffee','uglify', 'copy'])
