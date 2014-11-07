ActiveAdmin.register FeedItem do
  belongs_to :user
  config.sort_order = "created_at_desc"
end