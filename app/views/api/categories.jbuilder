json.array! @categories do |c|
  json.category do
    json.(c, :id, :name, :icon_url)
  end
end