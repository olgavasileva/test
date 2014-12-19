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

  # /admin/scenes/csv_report
  action_item only: :index do
    link_to "CSV Report", csv_report_admin_scenes_path(controller.params.merge(format: :csv))
  end

  collection_action :csv_report do
    property_keys = ItemProperty.order(:key).map(&:key).uniq

    headers["Content-Type"] = "text/csv"

    csv_body = CSV.generate do |csv|
      Studio.all.each do |studio|
        scenes = collection.where(studio_id:studio)
          if scenes.present?
          stickers = studio.stickers.order('stickers.priority ASC') # NOTE there are other sorts on the studio.sticker relation in the models

          csv << ["Studio ID", "Studio Name"]
          csv << [studio.id, studio.name]
          csv << []

          columns = [:id, :studio_id, :user_id, :username, :age, :gender, "cereal name", :image]
          stickers.each do |sticker|
            columns << sticker.display_name
          end
          property_keys.each do |key|
            columns << key
          end
          csv << columns

          scenes.each do |scene|
            line = []
            line << scene.id
            line << scene.studio_id
            line << scene.user_id
            line << scene.user.try(:username)
            line << scene.user.try(:age)
            line << scene.user.try(:gender)
            line << scene.name
            line << scene.image.url

            sticker_ids = scene.stickers.map(&:id)
            property_totals = {}
            stickers.each do |sticker|
              line << sticker_ids.count(sticker.id)
            end

            scene.stickers.each do |sticker|
              # Accumulate property totals
              sticker.item_properties.each do |property|
                property_totals[property.key] ||= 0.0
                property_totals[property.key] += property.value.to_f
              end
            end

            property_keys.each do |key|
              line << property_totals[key]
            end

            csv << line
          end

          csv << []
        end
      end
    end

    render text: csv_body
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