const fs = require("fs");
const copyfiles = require("copyfiles");

const dist = "./dist";

if (fs.existsSync(dist)) {
  fs.rmdirSync(dist, { recursive: true });
}

fs.mkdirSync(dist);

copyfiles(
  ["src/**/*", dist],
  {
    up: 1,
    exclude: "**/*.ts",
    all: false,
    soft: false,
  },
  function () {}
);
