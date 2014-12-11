ActiveAdmin.register User do
  menu parent: "Users", label: "Standard Users"
  permit_params :email, :password, :password_confirmation, role_ids: []

  index do
    selectable_column
    id_column
    column :username
    column :email
    column :roles do |u|
      u.roles.map{|r|r.name}.join ", "
    end
    column :current_sign_in_at
    column :sign_in_count
    column "Responses" do |u|
      u.responses.count
    end
    column "Items in Feed" do |u|
      link_to u.feed_items.count, admin_user_feed_items_path(u)
    end
    column "Actions" do |u|
      link_to "Reset this feed", reset_admin_user_path(u), method: :delete
    end
    column :created_at
    column "Scenes" do |user|
      link_to pluralize(user.scenes.count, 'Scene'), admin_user_scenes_path(user)
    end
    actions
  end

  member_action :reset, method: :delete do
    user = User.find params[:id]
    user.reset_feed!

    redirect_to admin_users_path, notice: "Feed has been reset for #{user.username}."
  end

  filter :email
  filter :username
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
      row :push_tokens do
        simple_format u.instances.where("push_token is not NULL").order("updated_at DESC").map{|i| "#{time_ago_in_words i.updated_at} ago: #{i.push_token}"}.join("\n")
      end
      row :studio_creation_links do
        Studio.all.map{|studio| link_to(studio.name, new_user_scene_path(u, studio_id:studio), target: :blank)}.join(", ").html_safe
      end
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
