CarrierWave.configure do |config|
  config.storage = :file
  config.asset_host = "http://localhost:3000" if Rails.env.development?
  config.asset_host = "http://localhost:3000" if Rails.env.test?
  config.asset_host = "http://crashmob.com" if Rails.env.production?
  config.asset_host = "http://2cents.crashmob.com" if Rails.env.staging?
  config.asset_host = "http://labs.crashmob.com" if Rails.env.labs?
end