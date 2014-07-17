class ResponsesController < ApplicationController
  def create
    case params[:commit]
    when "Submit"
      @response = Response.new response_params
      authorize @response
      if @response.save
        flash[:success] = "Thank you for your response!"
      else
        flash[:error] = "Unable to save your response."
      end

      redirect_to root_path
    when "Skip"
      flash[:warning] = "Question skipped"
      redirect_to root_path
    end
  end


  protected

    def response_params
      raise NotImplementedError.new("You must implement response_params.")
    end
end