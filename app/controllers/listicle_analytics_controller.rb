class ListicleAnalyticsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound do
    head 404
  end

  layout 'pixel_admin'

  def show
    @listicle = current_user.listicles.find(params[:listicle_id])
    authorize @listicle
    @question = @listicle.questions.first
    @demographics = DemographicSummary.aggregate_data_for_question(@question)
  end
end
