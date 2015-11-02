class AdvancedListiclesController < ApplicationController
  before_action :load_and_authorize

  def update
    AdvancedListicleParser.new(params[:advanced_text], @listicle).parse_and_save
    @listicle.update listicle_params
    respond_to do |format|
      format.html { redirect_to controller: :listicles, action: :index }
      format.json { render json: {form: render_to_string(partial: 'listicles/basic_form', formats: :html)}, status: :ok }
    end
  end

  private

  def load_and_authorize
    @listicle = current_user.listicles.find params[:listicle_id]
    authorize @listicle
  end

  def listicle_params
    params.require(:listicle).permit :item_separator_color, :vote_count_color, :arrows_default_color,
                                     :arrows_on_hover_color, :arrows_selected_color
  end

end
