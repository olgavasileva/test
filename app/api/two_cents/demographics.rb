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

      demographic = current_user.demographic || current_user.build_demographic
      demographic.update_from_provider_data! declared_params[:provider], declared_params[:version], declared_params[:raw_data]
    end
  end
end
