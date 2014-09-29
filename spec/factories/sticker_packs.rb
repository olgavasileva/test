FactoryGirl.define do
  factory :sticker_pack do
    display_name {generate :name}
  end
end