module.exports = {
  root: true,
  env: {
    browser: true,
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:prettier/recommended",
    "prettier/@typescript-eslint",
  ],
  parser: "@typescript-eslint/parser",
  plugins: ["@typescript-eslint", "prettier", "eslint-plugin-tsdoc"],
  parserOptions: {
    ecmaVersion: 2018,
    sourceType: "module",
  },
  rules: {
    "no-var": "error",
    "prefer-const": "warn",
  },
  overrides: [
    {
      files: ["src/typings/**/*.d.ts"],
      rules: {
        "no-unused-vars": "off",
      },
    },
  ],
  globals: {
    _: "readonly",
    E: "readonly",
    L: "readonly",
    baseclass: "readonly",
    custom: "readonly",
    dom: "readonly",
    form: "readonly",
    fs: "readonly",
    network: "readonly",
    poll: "readonly",
    uci: "readonly",
    ui: "readonly",
    v2ray: "readonly",
    view: "readonly",
  },
};
