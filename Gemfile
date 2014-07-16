source 'https://rubygems.org'
ruby '2.1.1'

gem 'rails', '4.1.1'
gem 'mysql2'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder'

gem 'will_paginate'

gem 'bcrypt-ruby'
gem 'jquery-ui-rails', '4.2.1'

gem 'activeadmin', github: 'gregbell/active_admin'
gem 'devise'
gem 'rolify'
gem 'pundit',           # simple, robust and scaleable authorization system
  git:"https://github.com/elabs/pundit.git",
  ref:"509be500c36c4a665b2cb88ed188fc36ee41bdf8"

gem 'simple_form', '~> 3.1.0.rc1', github: 'plataformatec/simple_form', branch: 'master'

gem 'haml'

gem 'simple-navigation'

gem 'carrierwave'       # Image uploading and access
gem 'rmagick',          # Image manipulation
  require: false

gem 'grape',            # API DSL
  github: 'intridea/grape'
gem 'grape-rabl'        # rabl for Grape rendering
gem 'grape-swagger'     # API docs
gem 'swagger-ui_rails'  # API docs hosting

gem 'uuid'              # UUID generation
gem 'figaro'            # Supports application.yml and easy defaults override in specs

gem 'koala'             # Facebook graph and realtime access (for email, fid, friends, etc.)

gem 'hirb'
gem 'wirble'

group :development do
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'capistrano-rails-collection' # Adds some db related commands to cap, like seed
  gem 'thin'

  gem 'better_errors'               # More useful error pages in development
  gem 'binding_of_caller'           # Enables advanced features of better_errors
end

group :development, :test do
  gem 'pry'
  gem 'pry-debugger'                # Allow stepping and breakpoints in pry console
  gem 'pry-rails'                   # Use pry in the console
  gem 'spring'
end

group :test do
  gem 'rspec-rails'
  gem 'database_cleaner'
  gem 'selenium-webdriver'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'spring-commands-rspec'
end

gem 'rails_12factor',         group: :production
gem 'sdoc', require: false,   group: :doc