# Load the Rails application.
require File.expand_path('../application', __FILE__)

ENV['AWS_ACCESS_KEY'] = '12334124'
ENV['AWS_SECRET_ACCESS_KEY'] = '2131221'
ENV['AWS_REGION'] = 'adsfas'
# Initialize the Rails application.
LinkchatApp::Application.initialize!
