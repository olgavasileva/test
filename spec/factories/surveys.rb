FactoryGirl.define do
  factory :survey do
    association :user

    name 'Soda Pop Questionaire'
    thank_you_markdown '**Thank You**'

    trait :embeddable do
      after(:create) do |survey|
        questions = FactoryGirl.create_list(:image_choice_question, 2, {
          survey_id: survey.id,
          user: survey.user
        })

        questions.each do |question|
          FactoryGirl.create_list(:image_choice, 2, question: question)
        end
      end
    end
  end
end
