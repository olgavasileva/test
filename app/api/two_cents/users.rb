class TwoCents::Users < Grape::API
  resource :users do
    desc "Upload avatar."
    params do
      requires :image_url, type: String, desc: "URL to avatar image."
    end
    post 'avatar' do
      validate_user!

      image_url = params[:image_url]

      if URI(image_url).scheme.nil?
        UserAvatar.create!(user: current_user, image: open(image_url))
      else
        UserAvatar.create!(user: current_user, remote_image_url: image_url)
      end

      current_user.save!

      {}
    end
  end
end
