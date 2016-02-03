require 'mina/bundler'
require 'mina/rails'
require 'mina/whenever'
require 'mina/git'
require 'mina/rbenv'
require 'mina/puma'
require 'mina/nginx'
require 'mina/scp'
require 'pry'
require 'dotenv'

Dotenv.load(".env.#{ENV["RAILS_ENV"]}")

################################################################################
settings.rake_assets_precompile = "RAILS_ENV=production bundle exec rake assets:precompile RAILS_GROUPS=assets"

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

current_root = File.expand_path '../', __FILE__
node_path    = ENV['MINA_NODE_PATH'] 

set :domain,      ENV['MINA_DOMAIN']
set :application, ENV['MINA_APPLICATION']
set :server_name, ENV['MINA_SERVER_NAME']
set :deploy_to,   ENV['MINA_DEPLOY']
set :repository,  'git@bitbucket.org:ablebeam/kiosk.git'
set :branch,      'master'
set :puma_config, "#{deploy_to}/#{shared_path}/config/puma/#{ENV['RAILS_ENV']}.rb"

set :shared_paths, [
  'config/database.yml', 'log', 'config/secrets.yml', 'config/application.yml',
  'tmp', 'public', 'vendor/assets/bower_components'
]


task :environment do
  invoke :'rbenv:load'
  queue! %(export NODE_PATH="#{node_path}")
  queue! %(export PATH="#{node_path}:$PATH")
  queue! %[mkdir -p "#{deploy_to}/shared/public"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public"]
  queue! %[mkdir -p "#{deploy_to}/shared/vendor/assets/bower_components"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/vendor/assets/bower_components"]
end

task :setup => :environment do

  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/tmp/sockets")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp/sockets")
  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/tmp/pids")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp/pids")

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/server"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/server"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]

  queue! %[dropdb kiosk]
  queue! %[createdb kiosk]

end

desc "Upload config files"
task :upload_config => :environment do
  scp_upload("#{current_root}/secrets/database.yml", "#{deploy_to}/#{shared_path}/config/database.yml")
  scp_upload("#{current_root}/secrets/secrets.yml", "#{deploy_to}/#{shared_path}/config/secrets.yml")
  scp_upload("#{current_root}/application.yml", "#{deploy_to}/#{shared_path}/config/application.yml")

  scp_upload("#{current_root}/server/kiosk.conf",       "#{deploy_to}/#{shared_path}/server/kiosk.conf")
  scp_upload("#{current_root}/server/nginx.conf",       "#{deploy_to}/#{shared_path}/server/nginx.conf")
  scp_upload("#{current_root}/server/puma.monit",       "#{deploy_to}/#{shared_path}/server/puma.monit")
  scp_upload("#{current_root}/server/resque.monit",     "#{deploy_to}/#{shared_path}/server/resque.monit")
  scp_upload("#{current_root}/server/clockwork.monit",  "#{deploy_to}/#{shared_path}/server/clockwork.monit")
end

desc "Install assets with bower."
task :bower_install => :environment do
  queue! %(RAILS_ENV=production bundle exec rake bower:install)
end

desc "Restart Resque workers"
task :restart_resque => :environment do
  queue! %(RAILS_ENV=production rake resque:restart_workers)
end

desc "Disable ActiveAdmin before running migrations"
task :disable_active_admin => environment do
  queue! %(mkdir -p #{deploy_to}/current/app/admin/)
  queue! %(mv #{deploy_to}/current/app/admin/ #{deploy_to}/current/admin/ 2>/dev/null)
end

desc "Enable ActiveAdmin after running migrations"
task :enable_active_admin => environment do
  queue! %(mv #{deploy_to}/current/admin/ #{deploy_to}/current/app/admin/ 2>/dev/null)
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
    invoke :'disable_active_admin'
    invoke :'rails:db_migrate'
    invoke :'enable_active_admin'
    invoke :'bower_install'
    invoke :'rails_patched:assets_precompile'
    invoke :'deploy:cleanup'
    invoke :'restart_resque'

    to :launch do
      queue "mkdir -p #{deploy_to}/#{current_path}/tmp/"

      invoke :'puma:phased_restart'
    end
  end
  invoke :'whenever:write'
end
