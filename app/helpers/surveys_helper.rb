module SurveysHelper
  def responding?
    params[:action] == 'create_response'
  end
end