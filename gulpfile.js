
del         = require('del');
gulp        = require('gulp');

coffee      = require('gulp-coffee');
notify      = require('gulp-notify');
plumber     = require('gulp-plumber');
slim        = require('gulp-slim');
stylus      = require('gulp-stylus');
uglify      = require('gulp-uglify');
usemin      = require('gulp-usemin');
webserver   = require('gulp-webserver');

gulp.task('slim', function() {
    gulp.src('src/**/*.slim')
        .pipe(plumber({
            errorHandler: notify.onError('<%= error.message %>') }))
        .pipe(slim())
        .pipe(gulp.dest('src'));
});

gulp.task('stylus', function() {
    gulp.src('src/**/*.stylus')
        .pipe(plumber({
            errorHandler: notify.onError('<%= error.message %>') }))
        .pipe(stylus({ compress: true }))
        .pipe(gulp.dest('src'));
});

gulp.task('coffee', function() {
    gulp.src('src/**/*.coffee')
        .pipe(plumber({
            errorHandler: notify.onError('<%= error.message %>') }))
        .pipe(coffee({ bare: true }))
        .pipe(uglify())
        .pipe(gulp.dest('src'));
});

gulp.task('default', ['slim', 'stylus', 'coffee'], function() {
    gulp.src('src').pipe(webserver());

    gulp.watch('src/**/*.slim', ['slim']);
    gulp.watch('src/**/*.stylus', ['stylus']);
    gulp.watch('src/**/*.coffee', ['coffee']);
});

gulp.task('clean', function(f) { del('build/*', f); });

gulp.task('build', ['clean', 'slim', 'stylus', 'coffee'], function() {
    gulp.src('build').pipe(webserver());

    gulp.src(['src/**/*', '!src/**/*.html', '!src/**/*.slim',
            '!src/**/*.stylus', '!src/*/scripts/*'])
        .pipe(gulp.dest('build'));

    gulp.src('src/**/*.html')
        .pipe(usemin())
        .pipe(gulp.dest('build/game'));
});
