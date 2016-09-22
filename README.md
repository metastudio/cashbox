# Codeship

[ ![Codeship Status for metastudio/cashbox](https://codeship.com/projects/c5311e10-4b14-0132-5fa4-06322762c3b0/status)](https://codeship.com/projects/46614)

# Parallel tests

## How to setup parallel_tests:

change config/database.yml

`database: cashbox_test`

to

`database: cashbox_test<%= ENV['TEST_ENV_NUMBER'] %>`

run rake task for prepare test databases

`rake parallel:setup`

## How to run parallel_tests:

`rake parallel:spec`

# API documentation path:

To watch API documentation visit path `/apipie`

# Linter

## Ruby

You don't need additional configuration to check ruby with linter. See only specified
package configuration for you editor.

## Javascript

To check javascript code you may use [eslint](http://eslint.org).
There are predefined rules in `.eslintrc.yml`.

To install eslint you need npm installed. Usually you may install it with node package.

```
npm install eslint -g
```

## Sublime Editor

To use eslint in sublime editor install next packages (check package page for instructions):

- [SublimeLinter](http://sublimelinter.readthedocs.io/en/latest/installation.html)
- [SublimeLinter-eslint](https://github.com/roadhump/SublimeLinter-eslint)
- [SublimeLinter-ruby](https://github.com/SublimeLinter/SublimeLinter-ruby)

