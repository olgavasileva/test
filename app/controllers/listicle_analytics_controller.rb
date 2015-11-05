class ListicleAnalyticsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound do
    head 404
  end

  layout 'pixel_admin'

  def show
    @listicle = current_user.listicles.find(params[:listicle_id])
    authorize @listicle
    @question = @listicle.questions.first
    respond_to do |format|
      format.html do
        @demographics = DemographicSummary.aggregate_data_for_question(@question)
      end
      format.csv do
        send_data ListicleDemographicsCSV.export(@listicle, us_only: true)
      end

      format.text do
        render text: ListicleDemographicsCSV.export(@listicle, us_only: true)
      end
    end
  end
end
