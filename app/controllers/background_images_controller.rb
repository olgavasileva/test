class BackgroundImagesController < ApplicationController
  def create
    model = controller_name.classify.constantize
    object = model.create! image_params

    respond json: object
  end

  private

  def image_params
    params.require(controller_name.singularize).permit(:image)
  end
end
