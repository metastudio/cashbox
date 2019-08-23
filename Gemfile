source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.3'

# Use postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'bootsnap', require: false

# Asset libraries
gem 'jquery-rails', '>= 4.3.4'
gem 'bootstrap-sass', '~> 3.4.0'
gem 'momentjs-rails', '>= 2.17.1'
gem 'jquery-ui-rails', '>= 6.0.1'
gem 'bootstrap-datepicker-rails', '= 1.6.4.1'
gem 'select2-rails', '~> 3.5.9.3'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
gem 'active_model_serializers', '~> 0.10.7'

gem 'slim-rails', '>= 3.1.3'
gem 'recursive-open-struct'
gem 'devise', '>= 4.6.0'
gem 'simple_form', '>= 3.5.0'
gem 'money-rails', '~> 1.10.0'
gem 'kaminari', '>= 1.1.1'
gem 'pundit'
gem 'enumerize'
gem 'has_secure_token', '~>0.0.2'
gem "paranoia"
gem 'ransack', '>= 1.8.7'
gem 'rollbar', '~> 2.15', '>= 2.15.5'
gem 'acts_as_list'
gem 'active_link_to', '>= 1.0.5'
gem 'russian_central_bank'
gem 'gon', '>= 6.2.0'
gem 'whenever', require: false
gem 'cocoon'
gem 'date_validator'
gem 'wicked_pdf', '~> 1.1.0'
gem 'wkhtmltopdf-binary', '= 0.12.3.0'
gem 'puma'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'redis'
gem 'knock'
gem 'apipie-rails', '>= 0.5.6'
gem 'rack-cors', require: 'rack/cors'
gem 'nokogiri', '>= 1.8.3'
gem 'phony_rails'

group :development, :test do
  gem 'rspec-rails', '>= 3.8.0'
  gem 'rspec-collection_matchers'
  gem 'byebug', platform: :mri
  gem 'parallel_tests'
  gem 'faker'
  gem 'factory_bot_rails', '>= 4.8.2'
end

group :development do
  gem 'pry-rails'
  gem 'guard', require: false
  gem 'guard-rspec', require: false
  gem 'annotate', require: false
  gem 'web-console', '>= 3.5.1'
  gem 'listen'
  gem 'ruby_audit'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'spring-commands-rspec'

  # Deployment
  gem 'capistrano', '~> 3.6.1', require: false
  gem 'capistrano-rails',   '~> 1.1.7', require: false
  gem 'capistrano-bundler', '~> 1.1.4', require: false
  gem 'capistrano-rvm',   '~> 0.1.2', require: false
  gem 'capistrano3-unicorn', '~> 0.2.1', require: false
  gem 'slackistrano', '~> 0.1.0', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  # TODO: fix after release
  # https://github.com/thoughtbot/capybara-webkit/issues/1065
  gem 'capybara-webkit', git: 'https://github.com/thoughtbot/capybara-webkit.git'
  gem 'capybara'
  gem 'capybara-email'
  gem 'capybara-select2'
  gem 'capybara-screenshot'
  gem 'timecop'
  gem 'simplecov', require: false
end

group :staging do
  gem 'unicorn'
end
