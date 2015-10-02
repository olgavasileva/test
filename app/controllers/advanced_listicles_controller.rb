class AdvancedListiclesController < ApplicationController
  before_action :load_and_authorize, except: [:new]

  def new
    @listicle = current_user.listicles.new
    authorize @listicle
    render 'listicles/advanced_form', locals: {listicle: @listicle}
  end

  def create
  end

  def edit

  end

  def update
  end

  private

  def load_and_authorize
    @listicle = current_user.listicles.find params[:id]
    authorize @listicle
  end

  def listicle_params
    params.require(:listicle).permit :intro, :footer, :questions_attributes => [:body, :_destroy, :id]
  end
end
