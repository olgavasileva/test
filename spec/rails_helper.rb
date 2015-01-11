# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# For fixture_file_upload
include ActionDispatch::TestProcess

include RSpec::Mocks::ExampleMethods

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.before(:suite) do
    # reload all the models - CAUTION: while this is convenient, it causes after_create callbacks to be called twice and warnings on all constant declarations
    # Dir["#{Rails.root}/app/models/**/*.rb"].each{ |model| load model }
    LinkchatApp::Application.reload_routes!
    FactoryGirl.reload
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction
  end

  config.include Requests::JsonHelpers, type: :request

  config.before(:each) do
    mock_montage = instance_double("Magick::ImageList", write:nil)
    allow(Magick::ImageList).to receive_message_chain(:new, :montage => mock_montage)

    @twilio_request = double(:twilio_request)
    @twilio_account = double(:twilio, request:@twilio_request).as_null_object
    allow(Twilio::REST::Client).to receive_messages(new:@twilio_account)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.around(:each, type: :request) do |example|
    run_background_jobs_immediately do
      example.run
    end
  end

  config.include BackgroundJobs

  config.after(:each) do
    # Rails.cache.clear
  end
end
