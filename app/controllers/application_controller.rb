class ApplicationController < ActionController::Base
  include Pundit

  before_action :authenticate_user!

  before_action :find_recent_questions
  before_action :configure_devise_permitted_parameters, if: :devise_controller?
  before_action :initialize_for_apple_push_service
  # Verify that controller actions are authorized. Optional, but good.
  after_action :verify_authorized,  except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout :layout_by_resource


  def after_sign_in_path_for resource
    resource.kind_of?(User) && session[:demo] ? "/question" : super(resource)
  end

  def after_sign_out_path_for resource
    session[:demo] = nil
    super resource
  end

  protected

    # Find next newer question in the feed, or wrap around if at the last question
    def next_question question
      all_questions = policy_scope(Question).where.not(id:question.id)
      all_questions.where("questions.created_at <= ?",question.created_at).limit(1).first || all_questions.first
    end

    def configure_devise_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) << :name
      devise_parameter_sanitizer.for(:sign_up) << :username
      devise_parameter_sanitizer.for(:sign_up) << :email

      devise_parameter_sanitizer.for(:sign_in) << :login

      # Need to add other user fields like gender etc.
      devise_parameter_sanitizer.for(:account_update) << :username
    end

  private

    def user_not_authorized
      flash[:error] = "You are not authorized to perform this action."
      redirect_to request.headers["Referer"] || root_path
    end

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
      @recent_questions ||= ::Question.order("created_at DESC").limit(2)
    end

    def initialize_for_apple_push_service
      APNS.host = 'gateway.push.apple.com'
      # gateway.sandbox.push.apple.com is default

      APNS.pem  = Rails.root + 'app/pem/crashmob_dev_push.pem'

      # this is the file you just created

      APNS.port = 2195
      # this is also the default. Shouldn't ever have to set this, but just in case Apple goes crazy, you can.
    end
end
