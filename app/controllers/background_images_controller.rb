class BackgroundImagesController < ApplicationController
  def create
    model = controller_name.classify.constantize
    object = model.create!(image_params)

    render json: { id: object.id, image_url: object.image_url }
  end

  private

  def image_params
    params.require(controller_name.singularize).permit(:image)
  end
end
