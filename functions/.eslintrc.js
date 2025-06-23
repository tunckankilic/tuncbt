module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],
    "max-len": ["error", {"code": 100}],
    "no-unused-vars": ["error", {"argsIgnorePattern": "^_"}],
    "camelcase": "off",
  },
  parserOptions: {
    ecmaVersion: 2018,
  },
};
