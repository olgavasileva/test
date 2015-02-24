require 'rails_helper'

RSpec.describe DemographicCSV do

  describe '.export' do
    it 'handles the #to_csv call' do
      expect_any_instance_of(DemographicCSV).to receive(:to_csv) { nil }
      DemographicCSV.export(Question.new)
    end
  end

  describe '#to_csv' do
    xit 'builds the csv correctly' do
      demo = DemographicCSV.new(Question.new(title: 'Test'))

      expect(demo).to receive(['Question', 'Title'])

      expect(demo).to receive(:choice_rows).ordered
        .and_yield([:choice_1])
        .and_yield([:choice_2])

      expect(demo.question_title_row).to eq(['Responses to:', 'Title'])

      expect(demo).to receive(:response_rows).ordered
        .and_yield([:response_1])
        .and_yield([:response_2])

      csv = demo.to_csv
      expect(csv.to_s).to eq "q_title\nchoice_1\nchoice_2\n\nq_title\nr_title\nresponse_1\nresponse_2\n"
    end
  end

  describe '#choices' do
    context 'for a non-ChoiceQuestion' do
      it 'delegates to Choice.none' do
        demo = DemographicCSV.new(Question.new)
        expect(demo.choices).to eq(Choice.none)
      end
    end

    context 'for a ChoiceQuestion or child' do
      it 'delegates to question.choices.order(:id)' do
        question = ChoiceQuestion.new

        choices = Choice.none
        expect(question).to receive(:choices).ordered { choices }
        expect(choices).to receive(:order).with(:id).ordered { [] }

        demo = DemographicCSV.new(question)
        demo.choices
      end
    end
  end

  describe '#choice_rows' do
    it 'yields the correct row data' do
      question = FactoryGirl.create(:text_choice_question)
      choices = FactoryGirl.create_list(:text_choice, 2, question: question)

      allow_any_instance_of(TextChoice).to receive(:response_ratio) { 0.50 }
      allow_any_instance_of(TextChoice).to receive(:web_image_url) { 'image.png' }

      rows = choices.each_with_index.map do |c, idx|
        ["Option ##{idx+1}", c.title, '50%', 'image.png']
      end

      demo = DemographicCSV.new(question)
      expect { |b| demo.choice_rows(&b) }.to yield_successive_args(*rows)
    end
  end
end
