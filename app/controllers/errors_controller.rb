class ErrorsController < ApplicationController
  skip_filter :authenticate_user!
  skip_filter :verify_authorized

  def error404
    render status: :not_found
  end

  def error500
    render status: :internal_server_error
  end
end
