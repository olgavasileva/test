module CampaignsHelper

  def iframe_code(survey, unit_name)
    unit = AdUnit.find_by name: unit_name.to_s

    "<iframe width=\"#{unit.width}\" height=\"#{unit.height}\"
src=\"#{qp_start_url(survey.uuid, unit_name)}\" frameborder=\"0\"></iframe>"
  end
end
