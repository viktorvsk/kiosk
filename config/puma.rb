deploy_to = '/home/vvsk/kiosk'
workers Integer(ENV['PUMA_WORKERS'] || 3)
threads Integer(ENV['MIN_THREADS']  || 16), Integer(ENV['MAX_THREADS'] || 16)
environment    'production'
daemonize       true
# rackup "#{deploy_to}/current/config.ru"
preload_app!
backlog = Integer(ENV['PUMA_BACKLOG'] || 20)

directory       "#{deploy_to}/current"
pidfile         "#{deploy_to}/shared/tmp/pids/puma.pid"
state_path      "#{deploy_to}/shared/tmp/sockets/puma.state"
stdout_redirect "#{deploy_to}/shared/log/puma.stdout.log", "#{deploy_to}/shared/log/puma.stderr.log"
bind            "unix://#{deploy_to}/shared/tmp/sockets/kiosk.sock"
activate_control_app "unix://#{deploy_to}/shared/tmp/sockets/pumactl.sock"


on_worker_boot do
  # worker specific setup
  ActiveSupport.on_load(:active_record) do
    config = ActiveRecord::Base.configurations[Rails.env] ||
                Rails.application.config.database_configuration[Rails.env]
    config['pool'] = ENV['MAX_THREADS'] || 16
    ActiveRecord::Base.establish_connection(config)
  end
end
