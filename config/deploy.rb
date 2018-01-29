set :application, 'cashbox'
set :repo_url, 'git@github.com:metastudio/cashbox.git'
set :scm, :git

set :linked_files, %w{config/database.yml config/config.yml config/cable.yml}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads}
set :bundle_gemfile, 'Gemfile'

set :keep_releases, 5

set :slack_team,    "metastudiohq"
set :slack_token,   "IbhiHvzuGfjdAX5A9OUqaI8V"
set :slack_channel, ->{ '#cashbox' }
set :slack_via_slackbot, ->{ true }
set :slack_msg_starting, ->{ ":pray: #{ENV['USER'] || ENV['USERNAME']} has started deploying branch #{fetch :branch} of #{fetch :application} to #{fetch :rails_env, 'production'}." }
set :slack_msg_finished, ->{ ":tada: #{ENV['USER'] || ENV['USERNAME']} has finished deploying branch #{fetch :branch} of #{fetch :application} to #{fetch :rails_env, 'production'}." }
set :slack_msg_failed,   ->{ ":trollface: :headbang: *ERROR!* #{ENV['USER'] || ENV['USERNAME']} failed to deploy branch #{fetch :branch} of #{fetch :application} to #{fetch :rails_env, 'production'}." }

set :rollbar_token, 'baf56cf5e8054cb2823811018eef04a6'
set :rollbar_env,  Proc.new { fetch :stage }
set :rollbar_role, Proc.new { :app }

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

namespace :deploy do
  task :restart do
    invoke 'unicorn:restart'
  end

  after :publishing, :restart
  after :finishing,  :cleanup
end

#after 'deploy:restart', 'unicorn:restart'
