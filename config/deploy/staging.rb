# Capistrano staging config
set :stage, :staging
set :rails_env, :staging

set :deploy_to, '/var/www/rails/cashbox.metastudiohq.com'

set :rvm_type, :system
set :rvm_ruby_version, 'ruby-2.1.1@cashbox'

server 'metastudio.ru', user: 'admin', roles: %w{web app db worker}
