class ApplicationController < ActionController::Base
  include Pundit

  before_action :find_recent_questions
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Verify that controller actions are authorized. Optional, but good.
  after_action :verify_authorized,  except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # layout "clean_canvas"
  layout :layout_by_resource


  protected

    def next_question question
      question_ids = policy_scope(Question).pluck(:id)
      index = question_ids.find_index question.id
      Question.find question_ids[index + 1] if index < question_ids.count - 1
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :username, :email, :password, :password_confirmation, :remember_me) }
      devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }

      # Need to add other user fields like gender etc.
      devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
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
end
