var gulp    = require('gulp');
var babel   = require('gulp-babel');
var mocha   = require('gulp-mocha');
// var through = require('through'); // for making arbitrary streams... i think
// var EmitJson = function() {
// }

var File = require('vinyl');
var JsonFile = new File({
  cwd: "/",
  base: "/",
  path: "/package.json",
  contents: new Buffer("test = 123")
});

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
  // gulp.dest('package.json').end(new JsonFile())
  return new JsonFile().pipe(gulp.dest('package.json'));
});
