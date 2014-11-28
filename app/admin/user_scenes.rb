ActiveAdmin.register Scene do
  menu label: "Scenes"

  belongs_to :user

  index do
    column :id
    column :name
    column :image do |s|
      link_to image_tag(s.image, style:"max-width: 200px"), s.image.url, target: :blank
    end
    column "Created At" do |s|
      "#{time_ago_in_words s.created_at} ago"
    end
    actions
  end
end