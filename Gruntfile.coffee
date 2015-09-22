module.exports = (grunt) -> 
	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'
		less:
			production:
				files:
					'styles/style.css': 'styles/style.less'
		cssmin:
			target:
				files: [
					expand: true
					cwd: 'styles/'
					src: ['*.css', '!*.min.css']
					dest: 'styles/'
					ext: '.min.css'
				]
		coffee:
			compile:
					files:
						'js/game.js': 'src/*.coffee'
		uglify: 
			build:
				src: 'js/<%= pkg.name %>.js',
				dest: 'js/<%= pkg.name %>.min.js'
		
	grunt.loadNpmTasks 'grunt-contrib-less'
	grunt.loadNpmTasks 'grunt-contrib-cssmin'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-uglify'

	grunt.registerTask 'default', ['less', 'cssmin', 'coffee','uglify']