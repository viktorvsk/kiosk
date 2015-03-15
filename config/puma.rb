deploy_to = '/home/vvsk/kiosk'

environment    'production'
daemonize       false

directory       deploy_to
pidfile         "#{deploy_to}/shared/tmp/pids/puma.pid"
state_path      "#{deploy_to}/shared/tmp/pids/puma.state"
stdout_redirect "#{deploy_to}/log/puma.stdout.log", "#{deploy_to}/log/puma.stderr.log"
bind            "unix:///#{deploy_to}/shared/sockets/kiosk.sock"
