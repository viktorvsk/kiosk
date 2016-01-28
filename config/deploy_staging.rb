require 'mina/bundler'
require 'mina/rails'
require 'mina/whenever'
require 'mina/git'
require 'mina/rbenv'
require 'mina/puma'
require 'mina/nginx'
require 'mina/scp'
node_path    = '/usr/bin/node'

set :domain,      'ubuntu@54.93.89.37'
set :application, 'staging'
set :server_name, 'staging.evotex.kh.ua'
set :deploy_to,   '/home/ubuntu/staging'
set :repository,  'git@bitbucket.org:ablebeam/kiosk.git'
set :branch,      'master'

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

set :shared_paths, [
  'config/database.yml', 'log', 'config/secrets.yml', 'config/application.yml',
  'tmp', 'public', 'vendor/assets/bower_components'
]

desc "Disable ActiveAdmin before running migrations"
task :disable_active_admin => environment do
  queue! %(mkdir -p #{deploy_to}/current/app/admin/)
  queue! %(mv #{deploy_to}/current/app/admin/ #{deploy_to}/current/admin/ 2>/dev/null)
end

task :enable_active_admin => environment do
  queue! %(mv #{deploy_to}/current/admin/ #{deploy_to}/current/app/admin/ 2>/dev/null)
end

desc "Install assets with bower."
task :bower_install => :environment do
  queue! %(RAILS_ENV=production bundle exec rake bower:install)
end

desc "Restart Resque workers"
task :restart_resque => :environment do
  queue! %(RAILS_ENV=production rake resque:restart_workers)
end

desc "Precompiles assets."
task :'assets_precompile:force' do
  queue %{
      echo "-----> Precompiling asset files"
      #{echo_cmd %[#{rake_assets_precompile}]}
    }
end

desc "Precompiles assets (skips if nothing has changed since the last release)."
task :'assets_precompile' do
  if ENV['force_assets']
    invoke :'assets_precompile:force'
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

end

task :enviroment do
  invoke :'rbenv:load'
  queue! %(export NODE_PATH="#{node_path}")
  queue! %(export PATH="#{node_path}:$PATH")
  queue! %[mkdir -p "#{deploy_to}/shared/public"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public"]
  queue! %[mkdir -p "#{deploy_to}/shared/vendor/assets/bower_components"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/vendor/assets/bower_components"]
end

desc 'Restart puma (phased restart)'
task phased_restart: :environment do
  queue! %[
      if [ -e '#{pumactl_socket}' ]; then
        cd #{deploy_to}/#{current_path} && CURRENT_PATH='/home/ubuntu/staging' bundle exec pumactl -S #{puma_state} --pidfile #{puma_pid} phased-restart
      else
        echo 'Puma is not running!';
      fi
    ]
end

desc "Deploys the current version to the staging server."
task :deploy => :enviroment do

  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'disable_active_admin'
    invoke :'rails:db_migrate'
    invoke :'enable_active_admin'
    invoke :'bower_install'
    invoke :'assets_precompile'
    invoke :'deploy:cleanup'
    invoke :'restart_resque'
    
    to :launch do
      queue "mkdir -p #{deploy_to}/#{current_path}/tmp/"
      invoke :'phased_restart'
    end
  end
  invoke :'whenever:write'
end
