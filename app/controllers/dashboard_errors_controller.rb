class DashboardErrorsController < ApplicationController
  include Gaffe::Errors
  skip_filter :authenticate_user!
  skip_filter :verify_authorized

  layout 'dashboard_errors'

  def show
    # Here, the `@exception` variable contains the original raised error
    render "dashboard_errors/#{@rescue_response}", status: @status_code
  end
end
