# Based on production defaults
require Rails.root.join("config/environments/development") #TODO removethis!

LinkchatApp::Application.configure do
  config.action_mailer.default_url_options = { host: 'labs.statisfy.co' }
  # config.assets.debug = true
end

LinkchatApp::Application.default_url_options = LinkchatApp::Application.config.action_mailer.default_url_options
