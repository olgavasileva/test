class InquiriesController < ApplicationController
  load_and_authorize_resource

  def create
    @inquiry.save!
  end

  protected

  def inquiry_params
    params.require(:inquiry).permit(:name, :email, :message)
  end
end