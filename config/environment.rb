# Load the Rails application.
require File.expand_path('../application', __FILE__)

ENV['RAILS_ENV'] = 'development'
ENV['AWS_ACCESS_KEY'] = '1233213'
ENV['AWS_REGION'] = 'asdf'
ENV['AWS_SECRET_ACCESS_KEY'] = '3232'
# Initialize the Rails application.
LinkchatApp::Application.initialize!
