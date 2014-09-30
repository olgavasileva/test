# Based on production defaults
require Rails.root.join("config/environments/production")
ENV['AWS_ACCESS_KEY'] = 'ASD'
ENV['AWS_SECRET_ACCESS_KEY'] = 'ASD'
ENV['AWS_REGION'] = 'ASD'
ENV['AWS_BUCKET'] = 'ASD'

LinkchatApp::Application.configure do

end
