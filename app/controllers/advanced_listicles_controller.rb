class AdvancedListiclesController < ApplicationController
  before_action :load_and_authorize

  # def new
  #   @listicle = current_user.listicles.new
  #   authorize @listicle
  #   render 'listicles/advanced_form', locals: {listicle: @listicle}
  # end

  def show
    render 'listicles/advanced_form'
  end

  def update
    # @listicle.update listicle_params
    respond_to do |format|
      format.html { redirect_to controller: 'listicles', action: 'index', status: :ok }
      format.json { render json: {form: render_to_string(partial: 'listicles/basic_form', formats: :html)}, status: :ok}
    end
  end

  private

  def load_and_authorize
    @listicle = current_user.listicles.find params[:listicle_id]
    authorize @listicle
  end

end
