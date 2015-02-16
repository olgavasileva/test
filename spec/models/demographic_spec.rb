require 'rails_helper'

RSpec.describe Demographic do

  it { is_expected.to belong_to(:respondent) }

  describe 'validations' do
    it { is_expected.to allow_value(nil).for(:gender) }
    it { is_expected.to allow_value(nil).for(:age_range) }
    it { is_expected.to allow_value(nil).for(:household_income) }
    it { is_expected.to allow_value(nil).for(:children) }
    it { is_expected.to allow_value(nil).for(:ethnicity) }
    it { is_expected.to allow_value(nil).for(:education_level) }
    it { is_expected.to allow_value(nil).for(:political_affiliation) }
    it { is_expected.to allow_value(nil).for(:political_engagement) }

    it { is_expected.to validate_inclusion_of(:gender).in_array(Demographic::GENDERS) }
    it { is_expected.to validate_inclusion_of(:age_range).in_array(Demographic::AGE_RANGES) }
    it { is_expected.to validate_inclusion_of(:household_income).in_array(Demographic::HOUSEHOLD_INCOMES) }
    it { is_expected.to validate_inclusion_of(:children).in_array(Demographic::CHILDRENS) }
    it { is_expected.to validate_inclusion_of(:ethnicity).in_array(Demographic::ETHNICITYS) }
    it { is_expected.to validate_inclusion_of(:education_level).in_array(Demographic::EDUCATION_LEVELS) }
    it { is_expected.to validate_inclusion_of(:political_affiliation).in_array(Demographic::POLITICAL_AFFILIATIONS) }
    it { is_expected.to validate_inclusion_of(:political_engagement).in_array(Demographic::POLITICAL_ENGAGEMENTS) }
  end

  describe '.aggregate_data_for_question' do
    let(:question) { double('Question') }

    it 'builds a demographics hash' do
      expect(Demographic).to receive(:aggregate_data_for)
        .with(question)
        .and_return(example: 'data')

      hash = Demographic.aggregate_data_for_question(question)
      expect(hash).to eq({question: question, example: 'data'})
    end
  end

  describe '.aggregate_data_for_choice' do
    let(:choice) { double('Choice') }

    it 'builds a demographics hash' do
      expect(Demographic).to receive(:aggregate_data_for)
        .with(choice)
        .and_return(example: 'data')

      hash = Demographic.aggregate_data_for_choice(choice)
      expect(hash).to eq({choice: choice, example: 'data'})
    end
  end

end
