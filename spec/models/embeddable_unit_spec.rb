require 'rails_helper'

RSpec.describe EmbeddableUnit do

  describe '#has_survey_questions?' do
    let(:survey) { Survey.new }
    subject { EmbeddableUnit.new(survey: survey).has_survey_questions? }

    context 'when no survey is present' do
      let(:survey) { nil }
      it { is_expected.to eq(false) }
    end

    context 'when no survey questions exist' do
      it { is_expected.to eq(false) }
    end

    context 'when survey questions exist' do
      before do
        allow(survey).to receive(:questions).and_return([Question.new])
      end

      it { is_expected.to eq(true) }
    end
  end
end
