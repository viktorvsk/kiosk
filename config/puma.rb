deploy_to = '/home/vvsk/kiosk'

workers 2
environment    'production'
daemonize       true
threads 0, 16
rackup "#{deploy_to}/current/config.ru"

directory       "#{deploy_to}/current"
pidfile         "#{deploy_to}/shared/tmp/pids/puma.pid"
state_path      "#{deploy_to}/shared/tmp/sockets/puma.state"
stdout_redirect "#{deploy_to}/shared/log/puma.stdout.log", "#{deploy_to}/shared/log/puma.stderr.log"
bind            "unix://#{deploy_to}/shared/tmp/sockets/kiosk.sock"
activate_control_app "unix://#{deploy_to}/shared/tmp/sockets/pumactl.sock"
