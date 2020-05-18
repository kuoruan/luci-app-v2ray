const child = require("child_process");
const fs = require("fs");
const gulp = require("gulp");
const terser = require("gulp-terser");
const ts = require("gulp-typescript");

const resDest = "package/htdocs/luci-static/resources";

const tsProject = ts.createProject("tsconfig.json");

function clean(...paths) {
  return child.spawn("rm", ["-rf", ...paths]);
}

gulp.task("clean-package", function () {
  return clean("package");
});

gulp.task("clean-output", function () {
  return clean("output");
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

gulp.task("i18n:scan", function () {
  const scan = child.spawn("./scripts/i18n-scan.pl", ["package"]);
  scan.stdout.pipe(fs.createWriteStream("public/po/templates/v2ray.pot"));
  return scan;
});

gulp.task("i18n:update", function () {
  return child.spawn("./scripts/i18n-update.pl", ["public/po"]);
});

gulp.task("i18n:sync", gulp.series("test", "i18n:scan", "i18n:update"));

gulp.task(
  "default",
  gulp.series("clean-package", gulp.parallel("build", "copy-public"))
);
