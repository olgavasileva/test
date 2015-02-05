class TwoCents::Demographics < Grape::API
  resource :demographics do

    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      optional :gender, type: String, values: Demographic::GENDERS
      optional :age_range, type: String, values: Demographic::AGE_RANGES
      optional :household_income, type: String, values: Demographic::HOUSEHOLD_INCOMES
      optional :children, type: String, values: Demographic::CHILDRENS
      optional :ethnicity, type: String, values: Demographic::ETHNICITYS
      optional :education_level, type: String, values: Demographic::EDUCATION_LEVELS
      optional :political_affiliation, type: String, values: Demographic::POLITICAL_AFFILIATIONS
      optional :political_engagement, type: String, values: Demographic::POLITICAL_ENGAGEMENTS
    end

    post '/', http_codes:[
      [200, "400 - Invalid params"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"]
    ] do
      validate_user!

      demographic = current_user.demographic || current_user.build_demographic

      demographic.gender = declared_params[:gender] if declared_params[:gender]
      demographic.age_range = declared_params[:age_range] if declared_params[:age_range]
      demographic.household_income = declared_params[:household_income] if declared_params[:household_income]
      demographic.children = declared_params[:children] if declared_params[:children]
      demographic.ethnicity = declared_params[:ethnicity] if declared_params[:ethnicity]
      demographic.education_level = declared_params[:education_level] if declared_params[:education_level]
      demographic.political_affiliation = declared_params[:political_affiliation] if declared_params[:political_affiliation]
      demographic.political_engagement = declared_params[:political_engagement] if declared_params[:political_engagement]

      demographic.save!
    end
  end
end
