CarrierWave.configure do |config|
  if Rails.env.test? || Rails.env.cucumber?
    config.storage = :file
    config.enable_processing = false
  else
    config.storage = :fog

    config.fog_credentials = {
      provider:              'AWS',                                 # required
      aws_access_key_id:     'asdfasdf',                 # required
      aws_secret_access_key: 'asdasdfasdf',          # required
      region:                'asdfasdds',                     # optional, defaults to 'us-east-1'
      # host:                  's3.example.com',                    # optional, defaults to nil
      # endpoint:              'https://s3.example.com:8080'        # optional, defaults to nil
    }
    config.fog_directory  = ENV['AWS_BUCKET']                       # required (on S3, this is the bucket)
    config.fog_public     = true                                    # optional, defaults to true
    config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
  end
end