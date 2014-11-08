ActiveAdmin.register Question do
  permit_params :id, :position, :category_id, :title

  filter :user
  filter :title
  filter :type
  filter :category

  index do
    selectable_column
    column :id
    column :type
    column :category
    column :title
    column :kind
    column :position
    column "In Feeds" do |q|
      q.feed_items.count
    end
    actions
  end

  form do |f|
    f.inputs f.object.type do
      f.input :position
      f.input :category
      f.input :title
    end
    f.actions
  end

end
