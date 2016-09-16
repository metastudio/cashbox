# Codeship

[ ![Codeship Status for metastudio/cashbox](https://codeship.com/projects/c5311e10-4b14-0132-5fa4-06322762c3b0/status)](https://codeship.com/projects/46614)

# How to setup parallel_tests:

change config/database.yml

`database: cashbox_test`

to

`database: cashbox_test<%= ENV['TEST_ENV_NUMBER'] %>`

run rake task for prepare test databases

`rake parallel:setup`

# How to run parallel_tests:

`rake parallel:spec`
