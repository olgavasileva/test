ActiveAdmin.register DataProvider do
  menu parent: "Demographics"

  permit_params :name

  config.sort_order = 'priority_asc'
  sortable # creates the controller action which handles the sorting

  index do
    sortable_handle_column
    column :name
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
    end
     f.actions
   end

end
