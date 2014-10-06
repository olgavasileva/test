ActiveAdmin.register Rpush::Notification, as: "Notifications" do
  menu parent: 'Push'

  filter :delivered
  filter :failed

  index do
    column "User" do |n|
      user = Instance.find_by(push_token:n.device_token).try(:user)
      user ? user.username : "Unknown"
    end
    column :badge
    column :sound
    column :alert
    column :delivered
    column :delivered_at
    column :failed
    column :failed_at
    column :error_code
    column :error_description
    column :created_at
  end
end
