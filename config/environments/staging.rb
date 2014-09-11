# Based on production defaults
require Rails.root.join("config/environments/production")


LinkchatApp::Application.configure do
  config.log_level = :debug
end
