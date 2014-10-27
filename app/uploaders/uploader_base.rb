class UploaderBase < CarrierWave::Uploader::Base
  def store_dir
    if Rails.env.production?
      File.join "uploads", Rails.env, model.class.to_s.underscore, mounted_as.to_s, model.id.to_s
    else
      # This is to ensure that each developer has their own files on S3 - be sure to add DEVELOPER_NAME in application.yml
      File.join "uploads", Rails.env, ENV['DEVELOPER_NAME'].to_s.parameterize.underscore, model.class.to_s.underscore, mounted_as.to_s, model.id.to_s
    end
  end
end