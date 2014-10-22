FactoryGirl.define do
  factory :device do
    platform 'iOS'
    manufacturer 'apple'
    model 'iPhone 5'
    os_version 'iOS 7.1'
    device_vendor_identifier {generate :device_vendor_identifier}
  end
end