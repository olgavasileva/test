# Based on production defaults
require Rails.root.join("config/environments/production")


LinkchatApp::Application.configure do
  config.action_mailer.default_url_options = { host: 'staging.statisfy.co' }
  config.log_level = :debug
end
