class BackgroundImagesController < ApplicationController
  def create
    binding.pry
    model = controller_name.classify.constantize
    object = model.new(image_params)
    authorize object
    object.save!

    render json: { id: object.id, image_url: object.image_url }
  end

  private

  def image_params
    params.require(controller_name.singularize).permit(:image)
  end
end
