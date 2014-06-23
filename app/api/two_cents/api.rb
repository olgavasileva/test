class TwoCents::API < Grape::API
  prefix 'v'
  version '2.0', using: :path

  helpers do
    def declared_params
      declared(params, include_missing: false)
    end

    def authorized_user!
      device = Device.find_by udid: declared_params[:udid]
      fail! 403, "forbidden: unregistered device, access denied" unless device

      ownership = Ownership.find_by(device_id: device.id, remember_token: declared_params[:remember_token])
      fail! 403, "forbidden: invalid session, access denied" unless ownership

      User.find_by(id: ownership.user_id)
    end

    def current_user
      @current_user ||= authorized_user!
    end

    def fail! code, message
      error!({error:message, error_code:code}, 400)
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    Rack::Response.new({
                         error_code: 404,
                         error_message: e.message
    }.to_json, 404).finish
  end

  rescue_from :all do |e|
    Rack::Response.new({
                         error_code: 500,
                         error_message: e.message
    }.to_json, 500).finish
  end

  mount Users

  add_swagger_documentation api_version:'2.0', mount_path: "/docs", markdown:true unless Rails.env.production?
end
