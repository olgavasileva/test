# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence :name do |n|
    "Name#{n}"
  end

  sequence :username do |n|
    "Username#{n}"
  end

  sequence :email_address do |n|
    "someone#{n}@statisfy.co"
  end

  sequence :password do |n|
    "password#{n}"
  end

  sequence :birthdate do |n|
    "1990-02-06"
  end

  sequence :gender do |n|
    "male"
  end

  sequence :device_vendor_identifier do |n|
    "DeviceVendorIdentifier_#{n}"
  end

  sequence :uuid do |n|
    "UUID#{n}"
  end

  sequence :apn_token do |n|
    sprintf("00000000000000000000000000000000000000000000000000000000%0.8d",n)
  end

  sequence :auth_token do |n|
    "AUTH_TOKEN_#{n}"
  end

  sequence :description do |n|
    "Description #{n}"
  end

  sequence :image do |n|
    Rack::Test::UploadedFile.new File.join("spec","factories","fixtures","images","Example.jpg")
  end

  sequence :sample_image_url do |n|
    File.join(Rails.root, "spec","factories","fixtures","images","Example.jpg")
  end

  sequence :body do |n|
    "Body #{n}"
  end
end
