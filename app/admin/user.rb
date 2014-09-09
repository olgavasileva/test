ActiveAdmin.register User do
  menu parent: "Users", label: "Standard Users"
  permit_params :email, :password, :password_confirmation, role_ids: []

  index do
    selectable_column
    id_column
    column :email
    column :roles do |u|
      u.roles.map{|r|r.name}.join ", "
    end
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :roles, as: :check_boxes
    end
    f.actions
  end

  show do |u|
    attributes_table do
      row :email
      row :roles do
        u.roles.map{|r|r.name}.join ", "
      end
      rows :current_sign_in_at, :sign_in_count, :created_at
    end
  end

  # Allow form to be submitted without a password
  controller do
    def update
      if params[:user][:password].blank?
        params[:user].delete "password"
        params[:user].delete "password_confirmation"
      end

      super
    end
  end

end
