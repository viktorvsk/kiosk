# Readme

* Ruby 2.2.4

* Rails 4.2.6

ansible-playbook -i ansible/inventory/staging deploy.yml -t prepare
RAILS_ENV=staging mina deploy_cold
RAILS_ENV=staging mina deploy
