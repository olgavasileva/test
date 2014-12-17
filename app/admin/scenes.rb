ActiveAdmin.register Scene do
  menu label: "Scenes", parent: 'Studios'

  belongs_to :user, optional:true

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

  csv do
    column :id
    column :studio_id
    column :user_id
    column("username") {|scene| scene.user.try :username}
    column("age") {|scene| scene.user.try :age}
    column("gender") {|scene| scene.user.try :gender}
    column("cereal name") {|scene| scene.name}
    column("image") {|scene| scene.image.url}
    column("stickers") do |scene|
      scene.stickers.map{|s| s.display_name}.join(", ")
    end
  end
end