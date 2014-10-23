class TwoCents::Users < Grape::API
  resource :users do
    desc "Upload avatar."
    params do
      requires :image, desc: "Avatar image."
    end
    post 'avatar' do
      validate_user!

      file = ActionDispatch::Http::UploadedFile.new(params[:image])
      current_user.avatar = file
      current_user.save!

      {}
    end
  end
end
