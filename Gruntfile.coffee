bower_filter = (type, component, relative_dir_path) ->
  relative_dir_path

bower_path_builder = (type, component, full_path) ->
  # The position of the start of the relative folders
  a = (full_path.indexOf component) + component.length + 1

  relative_path =
    if full_path.match ///.*\.[a-zA-Z0-9]{1,8}/// # is a file
      # Gets the position where the directory path ends
      b = full_path.split("/")
      b.pop()
      b = b.join("/").length

      full_path[a..b]
    else # is a directory
      full_path[a..]

  type + "/" + bower_filter type, component, relative_path

module.exports = (grunt) ->
  grunt.initConfig
    bower:
      install:
        options:
          copy: false
      realloc:
        options:
          install: false
          targetDir: "tmp/bower"
          layout: bower_path_builder
    clean:
      build:
        src: "dist"
      bower:
        src: "tmp/bower"
    compress:
      prod:
        options:
          archive: "dist/release.tar"
          mode: "tar"
        files: [
          expand: true
          cwd: "dist"
          src: ["**/**"]]
    copy:
      font:
        files: [
          {
            expand: true
            cwd: "src/font"
            src: "**/*.{eot,woff,woff2,ttf,svg}"
            dest: "dist/assets/font"},
          {
            expand: true
            cwd: "tmp/bower/font"
            src: "**/*.{eot,woff,woff2,ttf,svg}"
            dest: "dist/assets/font"}]
      js:
        expand: true
        cwd: "tmp/bower/js"
        src: "**/*.js"
        dest: "dist/assets/js/vendor"
    express:
      live:
        options:
          bases: ["dist"]
          livereload: grunt.option('port-live') || true
    imagemin:
      dev:
        options:
          optimizationLevel: 0
        files: x = [
          expand: true
          cwd: "src/img"
          src: ["**/*.{png,jpg,jpeg,gif,svg}"]
          dest: "dist/assets/img"]
      prod:
        options:
          optimizationLevel: 7
          progressive: false
          interlaced: false
        files: x
    jade:
      dev:
        options:
          pretty: true
        files: x  = [
          expand: true
          cwd: "src/jade"
          src: ["**/*.jade", "!includes/**"]
          dest: "dist"
          ext: ".html"]
      prod:
        options:
          options:
            pretty: false
            compileDebug: false
        files: x
    parallel:
      dev:
        options:
          grunt: true
        tasks: ["copy", "imagemin:dev", "jade:dev", "sass:dev", "uglify:dev"]
      prod:
        options:
          grunt: true
        tasks: ["copy", "imagemin:prod", "jade:prod", "sass:prod", "uglify:prod"]
    sass:
      dev:
        options:
          style: "nested"
          sourcemap: "file"
          trace: true
          unixNewlines: true
          compass: true
          loadPath: x = ["tmp/bower/sass"]
        files: y = [
          expand: true
          cwd: "src/sass"
          src: ["**/*.scss"]
          dest: "dist/assets/css"
          ext: ".css"]
      prod:
        options:
          style: "compressed"
          sourcemap: "none"
          unixNewlines: true
          compass: true
          loadPath: x
        files: y
    uglify:
      dev:
        options:
          preserveComments: "all"
          beautify: true
          sourceMap: true
          sourceMapIncludeSources: true
        files: x = {
          "dist/assets/js/custom.js": ["src/js/**/*.js"]}
      prod:
        options:
          preserveComments: "some"
          beautify: false
          compress:
            drop_console: true
        files: x
    watch:
      img:
        options: x
        files: ["src/img/**/*.{png,jpg,jpeg,gif,svg}"]
        tasks: ["imagemin:dev"]
      jade:
        options: x
        files: ["src/jade/**/*.{jade,json}"]
        tasks: ["jade:dev"]
      js:
        options: x
        files: ["src/js/**/*.js"]
        tasks: ["uglify:dev"]
      sass:
        options: x
        files: ["src/sass/**/*.scss"]
        tasks: ["sass:dev"]
      watch:
        options:
          spawn: false
          reload: true
        files: ["Gruntfile.coffee"]

  grunt.loadNpmTasks 'grunt-bower-task'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-compress'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-imagemin'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-express'
  grunt.loadNpmTasks 'grunt-parallel'

  grunt.registerTask "live", ["bower", "parallel:dev", "express", "watch"]

  grunt.registerTask "release", ["clean", "bower", "parallel:prod", "compress"]
