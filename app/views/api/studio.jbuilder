json.studio do
  json.(@studio, :display_name, :welcome_message, :scene_id, :updated_at)
  json.icon_url @studio.icon.web.url
end
