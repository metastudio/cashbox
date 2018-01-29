# Capistrano staging config
set :stage, :production
set :rails_env, :production
set :branch, :production
set :tmp_dir, '/tmp/cashbox_production'

set :deploy_to, '/var/www/rails/cashbox.metastudiohq.com'

set :rvm_type, :system
set :rvm_ruby_version, 'ruby-2.3.1@cashbox-production'

server 'metastudio.ru', user: 'deployer', roles: %w{web app db worker}
