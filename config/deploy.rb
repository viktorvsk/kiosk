require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'
require 'mina/puma'
require 'mina/nginx'
require 'mina/scp'

current_root = File.expand_path '../', __FILE__
node_path    = '/home/vvsk/.nvm/versions/node/v0.12.1/bin'

set :domain,      'vvsk@terenkur.com'
set :application, 'kiosk'
set :server_name, 'kiosk.evotex.kh.ua'
set :deploy_to,   '/home/vvsk/kiosk'
set :repository,  'git@bitbucket.org:ablebeam/kiosk.git'
set :branch,      'master'



set :shared_paths, [
  'config/database.yml', 'log', 'config/secrets.yml', 'config/application.yml', 'tmp',
  'public/uploads'
]

task :environment do
  invoke :'rbenv:load'
  queue! %(export NODE_PATH="#{node_path}")
  queue! %(export PATH="#{node_path}:$PATH")
  queue! %[mkdir -p "#{deploy_to}/shared/public/uploads"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/uploads"]
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
  queue! %(rake bower:install)
end

desc "test"
task :tes => :environment do
  invoke :'puma:start'
end

desc "Deploys the current version to the server."
task :deploy => :environment do

  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'bower_install'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    to :launch do
      queue "mkdir -p #{deploy_to}/#{current_path}/tmp/"
      Rake::Task['resque:restart_workers'].invoke
      invoke :'puma:phased_restart'
    end
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers

