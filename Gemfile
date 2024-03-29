source 'https://rubygems.org'

gem 'rails', '~> 4.2'
gem 'sprockets-rails', '2.3.3'
gem 'puma'
gem 'pg'
gem 'devise'
gem 'cancancan', '~> 1.8'
gem 'resque', '1.25.2'
gem 'ransack'
gem 'haml-rails'
gem 'redis-rails'
gem 'rails-settings-cached', '0.4.1'
gem 'kaminari'
gem 'ancestry'
gem 'whenever', require: false
gem 'carrierwave'
gem 'fog'

gem 'bower-rails', '~> 0.9.2'
gem 'ckeditor'
gem 'russian', '~> 0.6.0'
gem 'figaro'
gem 'mini_magick'
gem 'typhoeus'

gem 'jquery-rails'
gem 'bootstrap-sass', '~> 3.3.3'
gem 'select2-rails'

group :development do
  gem 'dotenv-rails'
  gem 'bootstrap-generators', '~> 3.3.1'
  gem 'rails-dev-boost',
       git: 'git://github.com/thedarkone/rails-dev-boost.git'
  gem 'rb-fsevent', '>= 0.9.1', require: RUBY_PLATFORM.include?('darwin')  && 'rb-fsevent'
  gem 'growl',                  require: RUBY_PLATFORM.include?('darwin')  && 'growl'
  gem 'rb-inotify', '>= 0.8.8', require: RUBY_PLATFORM.include?('linux')   && 'rb-inotify'
  gem 'libnotify',              require: RUBY_PLATFORM.include?('linux')   && 'rb-inotify'
  gem 'binding_of_caller'
  gem 'better_errors'
  gem 'awesome_print'
  gem 'quiet_assets'
  gem 'bullet'
  gem 'mina',       require: false
  gem 'mina-puma',  require: false
  gem 'mina-nginx', require: false
  gem 'mina-scp',   require: false
end

group :development, :test do
  gem 'byebug', '~> 5'
  gem 'spring'
  gem 'ffaker'
  gem 'factory_girl_rails'
end

group :production, :staging do
  gem 'rack-cache'
end

group :assets do
  gem 'sass-rails', '~> 5.0', require: false
  gem 'uglifier', '>= 1.3.0', require: false
  gem 'coffee-rails', '~> 4.1.0', require: false
  gem 'execjs', require: false
end

gem 'file_browser', path: 'file_browser'
gem 'browser'
gem 'roo', '~> 1'
gem 'nokogiri'
gem 'dullard', github: 'ablebeam/dullard'
gem 'auto_html'
