class ErrorsController < ApplicationController
  include Gaffe::Errors
  skip_filter :authenticate_user!
  skip_filter :verify_authorized

  layout 'errors'

  def show
    # Here, the `@exception` variable contains the original raised error
    render "errors/#{@rescue_response}", status: @status_code
  end

end
