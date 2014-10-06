class InquiriesController < ApplicationController
  def create
    @inquiry = Inquiry.new inquiry_params
    authorize @inquiry
    flash[:error] = "We were unable to send your message." unless @inquiry.save
  end

  protected

    def inquiry_params
      params.require(:inquiry).permit(:name, :email, :message)
    end

end