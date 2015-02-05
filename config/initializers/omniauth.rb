# OmniAuth configuration
OmniAuth.config.logger = Rails.logger

# OmniAuth Middleware
Rails.application.config.middleware.use OmniAuth::Builder do

  if ENV['FACEBOOK_APP_ID'] && ENV['FACEBOOK_APP_SECRET']
    provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], {
      scope: 'email,public_profile',
      secure_image_url: true,
      display: 'popup'
    }
  end
end
