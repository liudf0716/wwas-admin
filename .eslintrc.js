module.exports = {
  root: true,
  env: {
    node: true,
    browser: true,
    es6: true
  },
  extends: [
    'plugin:vue/essential', // Handles Vue parsing using vue-eslint-parser
    'eslint:recommended',
  ],
  parser: 'vue-eslint-parser', // Explicitly set vue-eslint-parser for .vue files
  parserOptions: {
    parser: '@babel/eslint-parser', // vue-eslint-parser will use this for <script> tags
    requireConfigFile: false,
    ecmaVersion: 2020,
    sourceType: 'module',
    babelOptions: {
      presets: [
        ["@babel/preset-env", { "modules": false, "useBuiltIns": "usage", "corejs": 3 }]
      ] // More complete preset-env config
    }
  },
  rules: {
    'no-console': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'vue/no-unused-vars': 'warn',
    'vue/no-unused-components': 'warn',
    'vue/multi-word-component-names': 'off',
    'semi': ['error', 'always'],
    'quotes': ['error', 'single'],
  },
  globals: {}
};
