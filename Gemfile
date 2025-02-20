source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '7.0.0'

# Use postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 1.3.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'bootsnap', require: false

# Asset libraries
gem 'jquery-rails', '~> 4.3.5'
gem 'bootstrap-sass', '~> 3.4.0'
gem 'momentjs-rails', '~> 2.20.1'
gem 'jquery-ui-rails', '~> 6.0.1'
gem 'bootstrap-datepicker-rails', '= 1.6.4.1'
gem 'select2-rails', '~> 3.5.9.3'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
gem 'active_model_serializers', '~> 0.10.10'

gem 'slim-rails', '>= 3.2.0'
gem 'recursive-open-struct'
gem 'devise', '>= 4.6.2'
gem 'simple_form', '>= 4.1.0'
gem 'money-rails', '~> 1.13.4'
gem 'kaminari', '>= 1.1.1'
gem 'pundit'
gem 'enumerize'
gem 'has_secure_token', '~>0.0.2'
gem 'paranoia'
gem 'ransack', '>= 2.1.1'
gem 'rollbar', '~> 2.15', '>= 2.15.5'
gem 'acts_as_list'
gem 'active_link_to', '>= 1.0.5'
gem 'russian_central_bank'
gem 'gon', '>= 6.2.1'
gem 'whenever', require: false
gem 'cocoon'
gem 'date_validator'
gem 'wicked_pdf', '~> 1.1.0'
gem 'wkhtmltopdf-binary', '= 0.12.3.0'
gem 'puma', '~> 5.6', '>= 5.6.9'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'redis'
gem 'knock', '>= 2.1.1'
gem 'apipie-rails', '>= 0.5.16'
gem 'rack-cors', require: 'rack/cors'
gem 'nokogiri', '>= 1.18.3'
gem 'phony_rails'
gem 'loofah', '~>2.19.1'
gem 'net-http'

group :development, :test do
  gem 'rspec-rails', '>= 3.8.2'
  gem 'rspec-collection_matchers'
  gem 'byebug', platform: :mri
  gem 'parallel_tests'
  gem 'faker'
  gem 'factory_bot_rails', '~> 5.0.2'
end

group :development do
  gem 'pry-rails'
  gem 'guard', require: false
  gem 'guard-rspec', require: false
  gem 'annotate', require: false
  gem 'web-console', '>= 3.7.0'
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
  gem 'webdrivers', '= 5.3'
  gem 'capybara', '>= 3.28.0'
  gem 'capybara-email', '>= 3.0.1'
  gem 'capybara-select2', '>= 1.0.1'
  gem 'capybara-screenshot', '>= 1.0.23'
  gem 'timecop'
  gem 'simplecov', require: false
end

group :staging do
  gem 'unicorn'
end
