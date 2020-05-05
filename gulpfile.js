const gulp = require("gulp");
const ts = require("gulp-typescript");
const terser = require("gulp-terser");
const rimraf = require("rimraf");

const resDest = "package/htdocs/luci-static/resources";

const tsProject = ts.createProject("tsconfig.json");

gulp.task("clean-package", function (cb) {
  rimraf("package", cb);
});

gulp.task("clean-output", function (cb) {
  rimraf("output", cb);
});

gulp.task("compile", function () {
  return tsProject
    .src()
    .pipe(tsProject())
    .js.pipe(
      terser({
        parse: {
          // allow 'return' outside of function
          bare_returns: true,
        },
        compress: {
          directives: false,
        },
      })
    )
    .pipe(gulp.dest("output"));
});

gulp.task("compile:test", function () {
  return tsProject.src().pipe(tsProject()).js.pipe(gulp.dest("output"));
});

gulp.task("copy-output", function () {
  return gulp.src("output/**").pipe(gulp.dest(resDest));
});

gulp.task("build", gulp.series("clean-output", "compile", "copy-output"));

gulp.task(
  "build:test",
  gulp.series("clean-output", "compile:test", "copy-output")
);

gulp.task("copy-public", function () {
  return gulp.src("public/**").pipe(gulp.dest("package"));
});

gulp.task(
  "test",
  gulp.series("clean-package", gulp.parallel("build:test", "copy-public"))
);

gulp.task(
  "default",
  gulp.series("clean-package", gulp.parallel("build", "copy-public"))
);
