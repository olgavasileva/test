class TwoCents::Demographics < Grape::API
  resource :demographics do

    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      requires :provider, type: String, values: %w(quantcast), desc: "Data provider.  For now, supply 'quantcast'"
      requires :version, type: String, values: %w(1.0), desc: "Version of the raw data.  For now, just supply 1.0"
      requires :raw_data, type: String, desc: "Raw textual data returned from the provider"
    end

    post '/', http_codes:[
      [200, "400 - Invalid params"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"]
    ] do
      validate_user!

      if declared_params[:provider] == 'quantcast'
        DataProvider.where(name:'quantcast').first_or_create
        demographic = current_user.demographics.quantcast.first_or_create
        demographic.ip_address = env['REMOTE_ADDR']
        demographic.user_agent = env['HTTP_USER_AGENT']
        demographic.update_from_provider_data! declared_params[:provider], declared_params[:version], declared_params[:raw_data]
      end
    end
  end
end
