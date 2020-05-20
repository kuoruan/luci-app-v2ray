const child = require("child_process");
const fs = require("fs");
const gulp = require("gulp");
const terser = require("gulp-terser");
const ts = require("gulp-typescript");
const replace = require("gulp-replace");

const pkg = require("./package.json");

process.env.LUCI_VERSION = pkg.version;

const resDest = "package/htdocs/luci-static/resources";

const tsProject = ts.createProject("tsconfig.json");

function clean(...paths) {
  return child.spawn("rm", ["-rf", ...paths]);
}

function replaceEnvs() {
  return replace(/process\.env\.(\w+)/g, function (_, pl) {
    return JSON.stringify(process.env[pl]);
  });
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
    .pipe(replaceEnvs())
    .pipe(gulp.dest("output"));
});

gulp.task("compile:test", function () {
  return tsProject
    .src()
    .pipe(tsProject())
    .js.pipe(replaceEnvs())
    .pipe(gulp.dest("output"));
});

gulp.task("copy-output", function () {
  return gulp.src("output/**").pipe(gulp.dest(resDest));
});

gulp.task("build", gulp.series("clean-output", "compile", "copy-output"));

gulp.task(
  "build:test",
  gulp.series("clean-output", "compile:test", "copy-output")
);

gulp.task("copy-makefile", function () {
  return gulp
    .src("public/Makefile")
    .pipe(
      replace(/#\{(\w+)\}/g, function (_, pl) {
        return pkg[pl];
      })
    )
    .pipe(gulp.dest("package"));
});

gulp.task("copy-public", function () {
  return gulp
    .src(["public/luasrc/**/*", "public/po/**/*.po", "public/root/**/*"], {
      cwd: ".",
      base: "public",
      dot: false,
    })
    .pipe(gulp.dest("package"));
});

gulp.task(
  "test",
  gulp.series(
    "clean-package",
    gulp.parallel("build:test", "copy-public", "copy-makefile")
  )
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
  gulp.series(
    "clean-package",
    gulp.parallel("build", "copy-public", "copy-makefile")
  )
);
