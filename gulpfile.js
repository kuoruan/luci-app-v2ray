const gulp = require("gulp");
const ts = require("gulp-typescript");
const terser = require("gulp-terser");
const rimraf = require("rimraf");

const outputDest = "package/htdocs/luci-static/resources/view/v2ray";

gulp.task("clean-package", function (cb) {
  rimraf("package", cb);
});

gulp.task("clean-output", function (cb) {
  rimraf("output", cb);
});

gulp.task("compile", function () {
  const tsProject = ts.createProject("tsconfig.json");

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

gulp.task("copy-output", function () {
  return gulp.src("output/**").pipe(gulp.dest(outputDest));
});

gulp.task("build", gulp.series("clean-output", "compile", "copy-output"));

gulp.task("copy-public", function () {
  return gulp.src("public/**").pipe(gulp.dest("package"));
});

gulp.task(
  "default",
  gulp.series("clean-package", gulp.parallel("build", "copy-public"))
);
