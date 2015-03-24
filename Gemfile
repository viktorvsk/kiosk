source 'https://rubygems.org'

# Basic
gem 'rails', '4.2.0'
gem 'pg'
gem 'puma'
gem 'bower-rails', '~> 0.9.2'
gem 'execjs'
# Schedule
# gem 'resque', '1.25.2'

# Translations
# gem 'russian', '~> 0.6.0'

# Robust
# gem 'parallel'
# gem 'activerecord-import', '0.4.0'
# gem 'benchmark-ips', require: false

# Security
# gem 'secure_headers', require: 'secure_headers'

# Search
# gem 'mysql2', '~> 0.3.13'
# gem 'thinking-sphinx', '~> 3.1.3'
gem 'ransack'

# Settings
gem 'figaro'
gem 'rails-settings-cached', '0.4.1'

# Markup Helpers
gem 'haml-rails'
gem 'simple_form'

# gem 'auto_html'
# gem 'gretel'

# Assets
# gem 'ckeditor'
gem 'jquery-rails'
gem 'bootstrap-sass', '~> 3.3.3'
# gem 'ace-rails-ap'
# gem 'jquery-ui-rails'
# gem 'select2-rails'

# API
gem 'jbuilder', '~> 2.0'

# Auth
gem 'devise'
# gem 'omniauth'
# gem 'omniauth-vkontakte'
# gem 'omniauth-facebook'
# gem 'cancancan', '~> 1.8'

# Refactoring
# gem 'draper'
# gem 'has_scope'

# ActivePricelist
gem 'roo'
gem 'simple_xlsx_reader'
gem 'nokogiri'
gem 'active_pricelist', github: 'ablebeam/active_pricelist'

# Images
# gem 'mini_magick'
# gem 'carrierwave'

# gem 'file_browser'

# SEO
# gem 'meta-tags'
# gem 'friendly_id', '~> 5.1.0'
# gem 'dynamic_sitemaps',   require: false
# gem 'sitemap_generator',  require: false

# Env helpers
# gem 'backup'
# gem 'rails_db_dump'

# ActiveRecord helpers
# gem 'foreigner'
# gem 'activevalidators', '~> 3.0.0'
# gem 'strip_attributes'
gem 'kaminari'

# ActiveRecord acts_as
# gem 'paranoia', '~> 2.0'
# gem 'paper_trail', '~> 4.0.0.beta'
# gem 'acts_as_commentable_with_threading'
# gem 'unread'
# gem 'awesome_nested_set'
# gem 'acts_as_list'

# Helpers
# gem 'monetize'
# gem 'money'
# gem 'faraday'

# group :doc do
#   gem 'sdoc', '~> 0.4.0'
#   gem 'w3c_validators'
# end

group :development do
  # Test coverage
  gem 'coverband'
  gem 'bootstrap-generators', '~> 3.3.1'

  # Debug
  gem 'binding_of_caller'
  gem 'better_errors'
  gem 'awesome_print'
  gem 'colorized'
  gem 'quiet_assets'
  gem 'bullet'
  # Works bad with js.erb render
  # gem 'rails_view_annotator'
  # gem 'xray-rails'
  gem 'peek'
  gem 'rack-livereload'

  # Watching
  # gem 'libnotify', require: false
  # gem 'ruby-growl'
  # gem 'ruby_gntp'
  # gem 'uniform_notifier'

  gem 'guard', '~> 2.8'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'guard-minitest'
  gem 'guard-rubocop'
  gem 'guard-livereload'
  gem 'spork-rails', github: 'sporkrb/spork-rails' # rubygems version not rails 4 compatible
  gem 'guard-spork'
  gem 'spork-testunit'
  gem 'ruby-prof'
  gem 'guard-brakeman'

  # Deployment
  gem 'mina'
  gem 'mina-puma',  require: false
  gem 'mina-nginx', require: false
  gem 'mina-scp',   require: false
end

group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'letter_opener'
  gem 'factory_girl_rails'
  gem 'ffaker'
  gem 'did_you_mean'
  gem 'rails-footnotes', '~> 4.0'
  gem 'zapata'
end

group :test do
  gem 'rspec-rails', '~> 3.0.0'
  gem 'rspec-mocks'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'database_cleaner'
  gem 'cucumber-rails', require: false
  gem 'shoulda-matchers', require: false
end

group :production do
  gem 'rack-cache'
  # gem 'rails_12factor'
end

group :assets do
  gem 'sass-rails', '~> 5.0'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.1.0'
  # gem 'autoprefixer-rails'
end

# group :system_helpers do
#   gem 'flog',                   require: false
#   gem 'rubocop',                require: false
#   gem 'lol_dba',                require: false
#   gem 'rails_best_practices',   require: false
#   gem 'brakeman',               require: false
#   gem 'cane',                   require: false
#   gem 'reek',                   require: false
#   gem 'rubycritic',             require: false
#   gem 'request-log-analyzer',   require: false
#   gem 'foreman',                require: false
#   gem 'bundler-audit',          require: false
#   gem 'clockwork',              require: false
#   gem 'god',                    require: false
# end

# Temporary
# gem 'fuzzy_match'
# gem 'amatch'
# gem 'browserlog'
