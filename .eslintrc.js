module.exports = {
  root: true,
  env: {
    browser: true,
    es6: true,
    node: true,
  },
  extends: ["eslint:recommended", "plugin:prettier/recommended"],
  parser: "@typescript-eslint/parser",
  plugins: ["@typescript-eslint", "prettier"],
  globals: {
    E: "readonly",
    L: "readonly",
    _: "readonly",
    baseclass: "readonly",
    custom: "readonly",
    form: "readonly",
    fs: "readonly",
    uci: "readonly",
    ui: "readonly",
    view: "readonly",
  },
};
