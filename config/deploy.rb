# Needed for multistage
require 'dotenv'
Dotenv.load(".env.#{ENV["RAILS_ENV"]}")

require 'mina/bundler'
require 'mina/rails'
require 'mina/whenever'
require 'mina/git'
require 'mina/rbenv'
require 'mina/puma'
require 'mina/nginx'
require 'mina/scp'


current_root = File.expand_path '../', __FILE__
node_path    = ENV['MINA_NODE_PATH']

set :domain,      ENV['MINA_DOMAIN']
set :application, ENV['MINA_APPLICATION']
set :server_name, ENV['MINA_SERVER_NAME']
set :port,        ENV['MINA_PORT'] || 22
set :deploy_to,   ENV['MINA_DEPLOY']
set :repository,  'git@bitbucket.org:ablebeam/kiosk.git'
set :branch,      ENV['MINA_BRANCH']
set :puma_config, "#{deploy_to}/#{current_path}/config/puma/#{ENV['RAILS_ENV']}.rb"
set :rails_env,   ENV['RAILS_ENV']

set :bundle_prefix, "RAILS_ENV=#{ENV['RAILS_ENV']} bundle exec"

set :shared_paths, [
  'config/database.yml', 'log', 'config/secrets.yml', 'config/application.yml',
  'tmp', 'public', 'vendor/assets/bower_components'
]

################################################################################
settings.rake_assets_precompile = "RAILS_ENV=#{ENV['RAILS_ENV']} bundle exec rake assets:precompile RAILS_GROUPS=assets"

def check_for_changes_script(options={})
  diffs = options[:at].map { |path|
    %[diff -r "#{deploy_to}/#{current_path}/#{path}" "./#{path}" 2>/dev/null]
  }.join("\n")

  unindent %[
    if [ -e "#{deploy_to}/#{current_path}/#{options[:check]}" ]; then
      count=`(
        #{reindent 4, diffs}
      ) | wc -l`

      if [ "$((count))" = "0" ]; then
        #{reindent 4, options[:skip]} &&
        exit
      else
        #{reindent 4, options[:changed]}
      fi
    else
      #{reindent 2, options[:default]}
    fi
  ]
end

namespace :rails_patched do
  # ### rails:assets_precompile:force
  desc "Precompiles assets."
  task :'assets_precompile:force' do
    queue %{
      echo "-----> Precompiling asset files"
      #{echo_cmd %[#{rake_assets_precompile}]}
    }
  end

  # ### rails:assets_precompile
  desc "Precompiles assets (skips if nothing has changed since the last release)."
  task :'assets_precompile' do
    if ENV['force_assets']
      invoke :'rails:assets_precompile:force'
    else
      message = verbose_mode? ?
        '$((count)) changes found, precompiling asset files' :
        'Precompiling asset files'

      queue check_for_changes_script \
        :check => 'public/assets/',
        :at => [*asset_paths],
        :skip => %[
          echo "-----> Skipping asset precompilation"
        ],
        :changed => %[
          echo "-----> #{message}"
          #{echo_cmd %[#{rake_assets_precompile}]}
        ],
        :default => %[
          echo "-----> Precompiling asset files"
          #{echo_cmd %[#{rake_assets_precompile}]}
        ]
    end
  end

end
################################################################################

task :environment do
  invoke :'rbenv:load'
  queue! %(export NODE_PATH="#{node_path}")
  queue! %(export PATH="#{node_path}:$PATH")
  queue! %[mkdir -p "#{deploy_to}/shared/public"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public"]
  queue! %[mkdir -p "#{deploy_to}/shared/vendor/assets/bower_components"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/vendor/assets/bower_components"]
end

desc "Install assets with bower."
task :bower_install => :environment do
  queue! %(RAILS_ENV=#{ENV["RAILS_ENV"]} bundle exec rake bower:install)
end

desc "Restart Resque workers"
task :restart_resque => :environment do
  queue! %(RAILS_ENV=#{ENV["RAILS_ENV"]} bundle exec rake resque:restart_workers)
end

desc 'Update crontab'
task update_crontab: :environment do
  invoke :'whenever:write'
end

desc "Deploys the current version to the server."
task :deploy => :environment do

  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'bower_install'
    invoke :'rails_patched:assets_precompile'
    invoke :'deploy:cleanup'

    to :launch do
      queue "mkdir -p #{deploy_to}/#{current_path}/tmp/"
      invoke :'puma:phased_restart'
      invoke :'restart_resque'
    end
  end
  invoke :'whenever:write'
end
