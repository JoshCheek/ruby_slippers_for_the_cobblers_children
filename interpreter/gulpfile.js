var gulp    = require('gulp');
var babel   = require('gulp-babel');
var mocha   = require('gulp-mocha');
// var through = require('through'); // for making arbitrary streams... i think
// var EmitJson = function() {
// }


gulp.task('default', function() {
  return gulp.src('src/app.js')
             .pipe(babel())
             .pipe(gulp.dest('dist'));
});

gulp.task('test', function() {
  return gulp.src('test.js', {read: false})
             .pipe(mocha({reporter: 'nyan'}));
});

gulp.task('package', function() {
  // doesn't work, "TypeError: Arguments to path.resolve must be strings"
  //   var dest = gulp.dest('outfile.txt');
  //   dest.write(['someshit']);
  //   return dest;

  // doesn't work: Error: Invalid glob argument: [object Object]
  // var result = gulp.src({name: 'mypackage', version: 'myversion'});

  // doesn't work, b/c I'm
  //   CALLED: on
  //   CALLED: on
  //   CALLED: on
  //   CALLED: on
  //   CALLED: resume
  var logCalled = function(name) {
    return function() {
      console.log("CALLED: "+name);
      return logCalled('CALLED FROM '+name);
    };
  };
  var stream = {
    on:            logCalled('on'),
    end:           logCalled('end'),
    push:          logCalled('push'),
    read:          logCalled('read'),
    wrap:          logCalled('wrap'),
    pipe:          logCalled('pipe'),
    write:         logCalled('write'),
    pause:         logCalled('pause'),
    resume:        logCalled('resume'),
    unpipe:        logCalled('unpipe'),
    domain:        logCalled('domain'),
    unshift:       logCalled('unshift'),
    destroy:       logCalled('destroy'),
    readable:      logCalled('readable'),
    writable:      logCalled('writable'),
    constructor:   logCalled('constructor'),
    setEncoding:   logCalled('setEncoding'),
    addListener:   logCalled('addListener'),
    allowHalfOpen: logCalled('allowHalfOpen')
  }

  return stream;
});
