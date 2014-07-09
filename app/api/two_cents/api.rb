class TwoCents::API < Grape::API
  prefix 'v'
  version '2.0', using: :path

  helpers do
    include Pundit

    def declared_params
      declared(params, include_missing: false)
    end

    def authorized_user!
      device = Device.find_by udid: declared_params[:udid]
      fail! 1003, "Forbidden: unregistered device, access denied" unless device

      ownership = Ownership.find_by(device_id: device.id, remember_token: declared_params[:remember_token])
      fail! 1004, "Forbidden: invalid session, access denied" unless ownership

      User.find_by(id: ownership.user_id)
    end

    def current_user
      @current_user ||= authorized_user!
    end

    def fail! code, message
      error!({error_code:code, error:message}, 401)
    end
  end

  rescue_from Grape::Exceptions::ValidationErrors do |e|
    Rack::Response.new({error_code: 1000, error_message: e.message}.to_json, 400).finish
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    Rack::Response.new({error_code: 1001, error_message: e.message}.to_json, 404).finish
  end

  rescue_from :all do |e|
    Rack::Response.new({error_code: 1002, error_message: e.message}.to_json, 500).finish
  end

  mount Users
  mount Questions

  add_swagger_documentation api_version:'2.0', mount_path: "/docs", markdown:true
end
