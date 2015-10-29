module CampaignsHelper

  UNITS = {
    medium_rectangle: {
        width: 300, height: 250
    },
    responsive_rectangle: {
        width: 330, height: 450
    }
  }

  def iframe_code(survey, unit_name)
    unit = UNITS[unit_name]

    "<iframe width=\"#{unit[:width]}\" height=\"#{unit[:height]}\"
src=\"#{qp_start_url(survey.uuid, unit_name)}\" frameborder=\"0\"></iframe>"
  end
end
