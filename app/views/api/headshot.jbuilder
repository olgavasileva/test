if @user.avatar
  json.avatar_url @user.avatar.image_url
else
  json.avatar_url gravatar_url(@user.email, default: :identicon)
end
