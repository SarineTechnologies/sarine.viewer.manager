'use strict';
module.exports = function(grunt) {
    require('load-grunt-tasks')(grunt)
    var files = ["Gruntfile.js", "package.json", "dist/*.js", "coffee/*.coffee", "bower.json", "release.cmd", "commit.cmd"]
    var message = "commit"
    grunt.initConfig({
        config: grunt.file.readJSON("bower.json"),
        version: {
            project: {
                src: ['bower.json', 'package.json']
            }
        },
        gitcommit: {
            all: {
                options: {
                    message: "<%= config.message %>",
                    force: true
                },
                files: {
                    src: files
                }
            }
        },
        gitpush: {
            all: {
                options: {
                    force: true
                },
                files: {
                    src: files
                }
            }
        },
        gitadd: {
            firstTimer: {
                option: {
                    force: true
                },
                files: {
                    src: files
                }
            }
        },
        gitpull: {
            build: {
                options: {
                    force: true
                },
                files: {
                    src: files
                }
            }
        },
        prompt: {
            all: {
                options: {
                    questions: [{
                        config: 'config.message',
                        type: 'input',
                        message: 'comment:\n',
                        default: 'commit'
                    }]
                }
            }
        }
    })
    grunt.registerTask('commit', ['prompt', 'gitadd', 'gitcommit', 'gitpush']);
    grunt.registerTask('release-git', ['version:project:patch', 'gitcommit', 'release']);
};