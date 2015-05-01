FactoryGirl.define do
  factory :survey do
    association :user

    name
    thank_you_markdown '**Thank You**'

    redirect { Survey::PERMITTED_REDIRECTS.first }
    redirect_url 'https://google.com'
    redirect_timeout 3000

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
