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

gem 'therubyracer'
gem 'less-rails'

gem 'bootstrap-sass'
gem 'autoprefixer-rails'

gem 'will_paginate'
gem 'kaminari'

gem 'bcrypt-ruby'
gem 'jquery-ui-rails'
gem 'touchpunch-rails'  # Convert touch events on mobile to jquery compatible mouse events

gem 'activeadmin', github: 'gregbell/active_admin'
gem 'just-datetime-picker'  # Date time picker for active admin
gem 'devise'
gem 'rolify'
gem 'pundit',           # simple, robust and scaleable authorization system
  git:"https://github.com/elabs/pundit.git",
  ref:"509be500c36c4a665b2cb88ed188fc36ee41bdf8"

gem 'simple_form', '~> 3.1.0.rc1', github: 'plataformatec/simple_form', branch: 'master'
gem 'cocoon'            # Dynamic nested forms using jQuery made easy; works with formtastic, simple_form or default forms
gem 'toastr-rails'      # Growl like notifications

gem 'haml'

gem 'simple-navigation'

gem 'carrierwave'       # Image uploading and access
gem 'fog'               # Cloud services intergration into carrierwave (e.g. s3)
gem 'rmagick',          # Image manipulation
  require: false

gem 'activeadmin-sortable'
gem 'acts_as_list'

gem 'attribute_defaults' # Provides an easy way to initialize attributes in active record
gem 'gravatar_for'

gem 'font-awesome-rails'  # Used by pixel-admin - The Font-Awesome web fonts and stylesheets as a Rails engine for use with the asset pipeline
gem "animate-rails"       # Used by pixel-admin



gem 'twilio-ruby'       # Used by backend for sending SMS messages to invited users


gem 'grape',            # API DSL
  github: 'intridea/grape'
gem 'grape-rabl'        # rabl for Grape rendering
gem 'grape-jbuilder'    # jbuilder for Grape rendering
gem 'grape-swagger'     # API docs
gem 'swagger-ui_rails'  # API docs hosting

gem 'uuid'              # UUID generation
gem 'figaro'            # Supports application.yml and easy defaults override in specs

gem 'koala'             # Facebook graph and realtime access (for email, fid, friends, etc.)

gem 'hirb'
gem 'wirble'

gem 'geocoder'          # Geolocation

gem 'randumb'           # Query results random ordering

gem 'acts-as-taggable-on'           # A tagging plugin for Rails applications that allows for custom tagging along dynamic contexts
gem 'roo'                           # Roo provides an interface to Open Office, Excel, and Google Spreadsheets
gem 'rubyzip'                       # rubyzip is a ruby library for reading and writing zip files
gem 'creek', '~> 1.0.3'             # Configurable streaming aggregator
gem 'rpush'
gem 'browser'                       # Browser detection

# pixel admin
gem 'morrisjs-rails'                # js: good-looking charts shouldn't be difficult
gem 'raphael-rails'                 # js: Cross-browser vector graphics the easy way (required by morrisjs-rails)
gem 'jquery-slimscroll-rails'       # js: transforms any div into a scrollable area with a nice scrollbar
gem 'easy_as_pie'                   # js+: Rails wrapper for easy-pie-chart
gem 'jquery-datatables-rails', '~> 2.2.3'
gem "select2-rails"                 # js: jQuery based replacement for select boxes

group :development do

  gem 'sqlite3'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'capistrano-rails-collection' # Adds some db related commands to cap, like seed
  gem 'thin'

  gem 'better_errors'               # More useful error pages in development
  gem 'binding_of_caller'           # Enables advanced features of better_errors

  gem 'xray-rails'                  # Reveal your UI's bones cmd-shift-x in browser
end

group :development, :test do
  gem 'pry'
  gem 'pry-byebug'                  # Allow stepping and breakpoints in pry console
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
