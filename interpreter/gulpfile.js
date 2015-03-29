var gulp  = require('gulp');
var babel = require('gulp-babel');
var mocha = require('gulp-mocha');


gulp.task('default', function() {
  return gulp.src('src/app.js')
             .pipe(babel())
             .pipe(gulp.dest('dist'));
});

gulp.task('mocha', function() {
  return gulp.src('test.js', {read: false})
             .pipe(mocha({reporter: 'nyan'}));
});

