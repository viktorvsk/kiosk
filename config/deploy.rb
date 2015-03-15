require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'
require 'mina/puma'
require 'mina/nginx'

set :domain,      'vvsk@terenkur.com'
set :application  'kiosk'
set :server_name  'kiosk.evotex.kh.ua'
set :deploy_to,   '/home/vvsk/kiosk'
set :repository,  'git@bitbucket.org:victorvsk/kiosk.git'
set :branch,      'master'

set :shared_paths, [
  'config/database.yml', 'log', 'tmp/sockets', 'tmp/pids',
  'config/secrets.yml'
]

task :environment do
  invoke :'rbenv:load'
end

task :setup => :environment do

  # Puma needs a place to store its pid file and socket file.
  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/tmp/sockets")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp/sockets")
  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/tmp/pids")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp/pids")

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]

  database_yml = File.read(Rails.root.join('config', 'secrets', 'database.yml'))
  queue! %[touch "#{deploy_to}/#{shared_path}/config/database.yml"]
  queue! %[echo "#{database_yml}" > #{deploy_to}/#{shared_path}/config/database.yml]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    to :launch do
      queue "mkdir -p #{deploy_to}/#{current_path}/tmp/"
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

