class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  before_action :find_recent_questions

  # Apply strong_parameters filtering before CanCan authorization
  # See https://github.com/ryanb/cancan/issues/571#issuecomment-10753675
  before_action do
    resource = controller_path.singularize.gsub('/', '_').to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # layout "clean_canvas"
  layout :layout_by_resource

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
  end

  def configure_devise_permitted_parameters
    registration_params = [:name, :email, :username, :password, :password_confirmation, :terms_and_conditions]

    if params[:action] == 'update'
      devise_parameter_sanitizer.for(:account_update) {
        |u| u.permit(registration_params << :current_password)
      }
    elsif params[:action] == 'create'
      devise_parameter_sanitizer.for(:sign_up) {
        |u| u.permit(registration_params)
      }
    end
  end

  private

    def layout_by_resource
      if devise_controller?
        case resource_name
        when :user
          "clean_canvas"
        when :partner
          "pixel_admin"
        end
      end || "clean_canvas"
    end

    def find_recent_questions
      @recent_questions ||= Question.order("created_at DESC").limit(2)
    end
end
