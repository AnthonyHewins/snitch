source 'https://rubygems.org'

ruby '2.6.0'

gem 'rails', '~> 5.2.2', '>= 5.2.2.1'

# Database
gem 'pg'

# Server
gem 'puma', '~> 3.11'
gem 'uglifier', '>= 1.3.0'
gem 'turbolinks', '~> 5'
gem 'therubyracer'
gem 'bootsnap', '>= 1.1.0', require: false

# Model
gem 'activerecord-import'

# Controller
gem 'will_paginate'

# View
gem 'semantic-ui-sass'
gem 'jquery-rails'

# APIs and crypto wrappers
gem 'net-sftp'
gem 'ed25519'
gem 'bcrypt'
gem 'bcrypt_pbkdf'
gem 'viewpoint'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'capistrano'
end

group :test do
  gem 'rspec-rails'
  gem 'ffaker'
  gem 'factory_bot'
  gem 'shoulda-matchers'
  gem 'database_cleaner'
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
end
