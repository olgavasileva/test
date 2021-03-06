class ApplicationController < ActionController::Base
  include Pundit
  include DemographicsHelper

  # Always use user_signed_in? in stead of testing current_user since current_user may be the "anonymous" user
  def user_signed_in?
    !!current_user && !current_user.anonymous?
  end

  # This will _always_ return a valid user - either the currently signed in user or the anonymous user if noone is signed in
  # Call user_signed_in? to find out if anyone is actually sigend in
  def current_user
    @devise_current_user ||= warden.authenticate(:scope => :user) || User.anonymous_user
  end

  before_action :sign_in_through_auth_token
  before_action :find_recent_questions
  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  before_action :set_csp

  # Verify that controller actions are authorized. Optional, but good.
  after_action :verify_authorized,  except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?

  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout :layout_by_resource

  def redirect_to(options = {}, response_status = {})
    ::Rails.logger.error("Redirected by #{caller(1).first rescue "unknown"}")
    super(options, response_status)
  end

  protected

    # Find next question in the feed, or wrap around if at the last question
    def next_question question
      feed_questions = current_user.anonymous? ? Question.active.order("questions.created_at DESC") : current_user.feed_questions
      feed_questions = policy_scope(feed_questions).where.not(id: question.id)

      feed_questions.where("questions.created_at <= ?",question.created_at).limit(1).first || feed_questions.first
    end

    def configure_devise_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) << :name
      devise_parameter_sanitizer.for(:sign_up) << :username
      devise_parameter_sanitizer.for(:sign_up) << :email

      devise_parameter_sanitizer.for(:sign_in) << :login

      # Need to add other user fields like gender etc.
      devise_parameter_sanitizer.for(:account_update) << :username
    end

    def allow_iframe
      response.headers.except! 'X-Frame-Options'
    end

  private

    def sign_in_through_auth_token
      if request.get? && params[:auth_token].present?
        instance = Instance.find_by(auth_token: params[:auth_token])
        sign_in instance.user if instance.try(:user).is_a?(User)
      end
    end

    def user_not_authorized
      flash[:error] = "You are not authorized to perform this action."
      if user_signed_in?
        redirect_to request.headers["Referer"] || root_path
      else
        session['user_return_to'] = request.headers["Referer"]
        redirect_to new_user_session_path
      end
    end

    def layout_by_resource
      if devise_controller?
        case resource_name
        when :user
          case params[:action]
            when 'new'
              'sign_page'
            when 'create'
              'sign_page'
            else
              'clean_canvas'
        end
        when :partner
          "pixel_admin"
        end
      end || "clean_canvas"
    end

    def find_recent_questions
      @recent_questions ||= ::Question.order("created_at DESC").limit(2)
    end

    def set_csp
      # response.headers['Content-Security-Policy'] = "default-src 'self' *; style-src 'self' * 'unsafe-inline'; script-src 'self' 'unsafe-eval'"
      # response.headers['Access-Control-Allow-Origin'] = '*'
    end

    def after_sign_out_path_for(resource_or_scope)
      Rails.env.development? ? root_path : 'http://www.statisfy.co'
    end

    def after_sign_in_path_for(resource)
      return admin_dashboard_path if resource.is_a?(AdminUser)
      if resource.publisher? || resource.is_pro?
        dashboard_user_path(resource)
      else
        current_user.web_app_url_with_auth
      end
    end

    def after_sign_up_path_for(resource)
      dashboard_user_path(resource)
    end

    def skip_authorization
      @_policy_scoped = true
      @_policy_authorized = true
    end
end
