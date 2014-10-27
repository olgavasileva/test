# Based on production defaults
require Rails.root.join("config/environments/production")

LinkchatApp::Application.configure do
  config.action_mailer.default_url_options = { host: 'labs.statisfy.co' }
end
