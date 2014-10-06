FactoryGirl.define do
  factory :order_choices_response, class: "OrderChoicesResponse" do
    association :choice, factory: :order_choice
    association :response, factory: :order_response

    position { rand(0..9) }
  end
end
