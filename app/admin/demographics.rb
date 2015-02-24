ActiveAdmin.register Demographic do
  menu parent: "Demographics"

  actions :index, :show

  index do
    column :id
    column :data_provider_name
    column :gender
    column :age_range
    column :household_income
    column :children
    column :ethnicity
    column :education_level
    column :political_affiliation
    column :political_engagement
    column :ip_address

    actions
  end
end