# OmniAuth configuration
OmniAuth.config.logger = Rails.logger

# OmniAuth Middleware
Rails.application.config.middleware.use OmniAuth::Builder do

  if ENV['FACEBOOK_APP_ID'] && ENV['FACEBOOK_APP_SECRET']
    provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], {
      setup: true,
      scope: 'email,public_profile',
      secure_image_url: true,
      display: 'popup'
    }
  end

  if ENV['TWITTER_API_KEY'] && ENV['TWITTER_API_SECRET']
    provider :twitter, ENV['TWITTER_API_KEY'], ENV['TWITTER_API_SECRET'], {
      setup: true,
      secure_image_url: true,
      x_auth_access_type: 'write'
    }
  end
end
