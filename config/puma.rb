deploy_to = '/home/vvsk/kiosk'

environment    'production'
daemonize       false
threads 0, 16
rackup "#{deploy_to}/current/config.ru"


directory       deploy_to
pidfile         "#{deploy_to}/shared/tmp/pids/puma.pid"
state_path      "#{deploy_to}/shared/tmp/pids/puma.state"
stdout_redirect "#{deploy_to}/shared/log/puma.stdout.log", "#{deploy_to}/shared/log/puma.stderr.log"
bind            "unix://#{deploy_to}/shared/tmp/sockets/kiosk.sock"
