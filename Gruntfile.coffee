module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      dev:
        expand: true
        cwd: 'src'
        src: [
          '*.coffee'
        ]
        dest: 'lib/'
        ext: '.js'
        options:
          bare: true
    mochaTest:
      dev:
        options:
          reporter: 'spec'
        src: ['test/*.coffee']
    env:
      test:
        NODE_ENV: 'test'
      'test-verbose':
        NODE_ENV: 'test-verbose'

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-env'

  grunt.registerTask 'build', ['coffee:dev']
  grunt.registerTask 'test', ['coffee:dev', 'env:test', 'mochaTest:dev']
  grunt.registerTask 'test-verbose', ['coffee:dev', 'env:test-verbose', 'mochaTest:dev']

  grunt.registerTask 'default', ->
    grunt.log.writeln """
    Usage:
      - grunt build
      - grunt test
    """.yellow