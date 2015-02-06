source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'

# Use postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.1'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Asset libraries
gem 'jquery-rails'
gem 'bootstrap-sass'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

gem 'slim-rails'
gem 'recursive-open-struct'
gem 'devise'
gem 'simple_form'
gem 'money-rails'
gem 'kaminari'
gem 'pundit'
gem 'enumerize'
gem 'ransack'

group :development, :test do
  gem 'rspec-rails'
end

group :development do
  gem 'pry-rails'
  gem 'thin'
  gem 'guard', require: false
  gem 'guard-rspec', require: false
  gem 'annotate', require: false

  # Deployment
  gem 'capistrano', '~> 3.3.0', require: false
  gem 'capistrano-rails',   '~> 1.1.1', require: false
  gem 'capistrano-bundler', '~> 1.1.3', require: false
  gem 'capistrano-rvm',   '~> 0.1.1', require: false
  gem 'capistrano3-unicorn', '~> 0.2.1', require: false
  gem 'slackistrano', '~> 0.1.0', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'capybara-email'
  gem 'capybara-webkit'
  gem 'headless'
  gem 'capybara-screenshot'
  gem 'timecop'
end

group :staging do
  gem 'unicorn'
end
