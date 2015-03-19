FactoryGirl.define do
  factory :survey do

    name 'Soda Pop Questionaire'

    trait :embeddable do
      after(:create) do |survey|
        survey.questions = FactoryGirl.create_list(:image_choice_question, 2)
        survey.questions.each do |question|
          FactoryGirl.create_list(:image_choice, 2, question: question)
        end

        survey.save!
      end
    end

    factory :embeddable_survey, traits: [:embeddable]
  end
end
