class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  before_action :build_canned_values

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
  layout "clean_canvas"

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

  def build_canned_values
    @canned_categories = %w{art illustration print web}
    @canned_feed = [
        {categories: %w{art web}, image_url: "b3/img/portfolio1.png", url:"portfolio-item.html", title: "Awesome portfolio item", primary_category: "Art"},
        {categories: %w{illustration}, image_url: "b3/img/portfolio2.png", url: "portfolio-item.html", title: "Awesome portfolio item", primary_category: "Web Design"}, 
        {categories: %w{print}, image_url: "b3/img/portfolio3.png", url: "portfolio-item.html", title: "Awesome portfolio item", primary_category: "Print"}, 
        {categories: %w{art web}, image_url: "b3/img/portfolio2.png", url: "portfolio-item.html", title: "Awesome portfolio item", primary_category: "Web design"}, 
        {categories: %w{art illustration}, image_url: "b3/img/portfolio1.png", url: "portfolio-item.html", title: "Awesome portfolio item", primary_category: "Illustration"}, 
        {categories: %w{print}, image_url: "b3/img/portfolio3.png", url: "portfolio-item.html", title: "Awesome portfolio item", primary_category: "Print"}, 
        {categories: %w{web}, image_url: "b3/img/portfolio2.png", url: "portfolio-item.html", title: "Awesome portfolio item", primary_category: "Web Design"}, 
        {categories: %w{art.illustration web}, image_url: "b3/img/portfolio3.png", url: "portfolio-item.html", title: "Awesome portfolio item", primary_category: "Art"}, 
        {categories: %w{print}, image_url: "b3/img/portfolio1.png", url: "portfolio-item.html", title: "Awesome portfolio item", primary_category: "Illustration"}
      ]
    @canned_recent_questions = [
      {image_url: "b3/img/portfolio1.png", date: Date.today - 2.days, title: "Randomized words which don't look embarrasing hidden."},
      {image_url: "b3/img/portfolio1.png", date: Date.today - 1.day, title: "Randomized words which don't look embarrasing hidden."}
    ]
  end
end
