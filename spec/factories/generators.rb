# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence :name do |n|
    "Name#{n}"
  end

  sequence :username do |n|
    "Username#{n}"
  end

  sequence :email_address do |n|
    "someone#{n}@crashmob.com"
  end

  sequence :password do |n|
    "password#{n}"
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
    fixture_file_upload File.join("spec","factories","fixtures","images","Example.jpg")
  end

  sequence :sample_image_url do |n|
    "/tmp/Vals-sample.jpg"
  end
end
