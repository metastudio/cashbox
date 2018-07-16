# Capistrano staging config
set :stage, :staging
set :rails_env, :staging

set :deploy_to, '/var/www/rails/staging.cashbox.metastudiohq.com'

set :rvm_type, :system
set :rvm_ruby_version, 'ruby-2.5.0@cashbox'

server 'metastudio.ru', user: 'deployer', roles: %w{web app db worker}
