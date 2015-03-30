var gulp    = require('gulp');
var babel   = require('gulp-babel');
var mocha   = require('gulp-mocha');
// var through = require('through'); // for making arbitrary streams... i think
// var EmitJson = function() {
// }

// faking a stream (and fuck you, Gulp, for making it take 2 fucking hours to figure this out)
// https://nodejs.org/api/stream.html#stream_api_for_stream_implementors
var stream = require('stream');

var MyStreamReadable = function() {
  stream.Readable.call(this);
}

// You *MUST* inherit first, or it will overwrite the method
// https://nodejs.org/api/util.html#util_util_inherits_constructor_superconstructor
require("util").inherits(MyStreamReadable, stream.Readable);
MyStreamReadable.prototype._read = function(numBytes) {
  // https://nodejs.org/api/stream.html#stream_readable_read_size_1
  // this fails, because file.relative is "undefined" in vinyl.
  // no fucking goddam clue why
  this.push('omg hello');
}


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
  var dest = gulp.dest('package.json');
  return new MyStreamReadable().pipe(dest);
});
