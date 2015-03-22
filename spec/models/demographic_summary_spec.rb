require 'rails_helper'

RSpec.describe DemographicSummary do
  it { is_expected.to belong_to(:respondent) }

  describe '.aggregate_data_for_question' do
    let(:question) { double('Question') }

    it 'builds a demographics hash' do
      expect(DemographicSummary).to receive(:aggregate_data_for)
        .with(question, {})
        .and_return(example: 'data')

      hash = DemographicSummary.aggregate_data_for_question(question)
      expect(hash).to eq({question: question, example: 'data'})
    end

    context "With a question and 3 responses" do
      let(:question) {FactoryGirl.create :question}
      let(:r1) {FactoryGirl.create :response, question:question }
      let(:r2) {FactoryGirl.create :response, question:question }
      let(:r3) {FactoryGirl.create :response, question:question }

      let!(:d1) {FactoryGirl.create :demographic, :quantcast, respondent:r1.user, gender:g1, age_range:a1, household_income:i1, children:c1, ethnicity:e1, education_level:el1}
      let!(:d2) {FactoryGirl.create :demographic, :quantcast, respondent:r2.user, gender:g2, age_range:a2, household_income:i2, children:c2, ethnicity:e2, education_level:el2}
      let!(:d3) {FactoryGirl.create :demographic, :quantcast, respondent:r3.user, gender:g3, age_range:a3, household_income:i3, children:c3, ethnicity:e3, education_level:el3}

      let(:g1) {'male'}
      let(:a1) {'18-24'}
      let(:i1) {'0-100k'}
      let(:c1) {'false'}
      let(:e1) {'asian'}
      let(:el1) {'college'}

      let(:g2) {'male'}
      let(:a2) {'18-24'}
      let(:i2) {'0-100k'}
      let(:c2) {'false'}
      let(:e2) {'asian'}
      let(:el2) {'college'}

      let(:g3) {'male'}
      let(:a3) {'18-24'}
      let(:i3) {'0-100k'}
      let(:c3) {'false'}
      let(:e3) {'asian'}
      let(:el3) {'college'}

      describe "Gender" do
        let!(:hash) {DemographicSummary.aggregate_data_for_question(question)}

        it {expect(hash['GENDER'][:largest_bucket][:name]).to eq 'Male'}
        it {expect(hash['GENDER'][:buckets][0][:name]).to eq "Male"}
        it {expect(hash['GENDER'][:buckets][0][:percent]).to eq 1.0}
        it {expect(hash['GENDER'][:buckets][1][:name]).to eq "Female"}
        it {expect(hash['GENDER'][:buckets][1][:percent]).to eq 0.0}

        context "When one response is female" do
          let(:g2) {'female'}

          it {expect(hash['GENDER'][:largest_bucket][:name]).to eq 'Male'}
          it {expect(hash['GENDER'][:buckets][0][:name]).to eq "Male"}
          it {expect(hash['GENDER'][:buckets][0][:percent]).to eq 2/3.0}
          it {expect(hash['GENDER'][:buckets][1][:name]).to eq "Female"}
          it {expect(hash['GENDER'][:buckets][1][:percent]).to eq 1/3.0}

          context "When one response has an unset gender" do
            let(:g3) {}
            it {expect(hash['GENDER'][:largest_bucket][:name]).to eq 'Male'}
            it {expect(hash['GENDER'][:buckets][0][:name]).to eq "Male"}
            it {expect(hash['GENDER'][:buckets][0][:percent]).to eq 1/2.0}
            it {expect(hash['GENDER'][:buckets][1][:name]).to eq "Female"}
            it {expect(hash['GENDER'][:buckets][1][:percent]).to eq 1/2.0}
          end
        end
      end

      context "When the first response is from a male, 20 year old, under 100k, no kids, asian, college graduate" do
        let(:g1) {'male'}
        let(:a1) {'18-24'}
        let(:i1) {'0-100k'}
        let(:c1) {'false'}
        let(:e1) {'asian'}
        let(:el1) {'college'}

        context "When the second response is from a femals, 54 year old, over 100k, kids, hispanic, with no college" do
          let(:g2) {'female'}
          let(:a2) {'45-54'}
          let(:i2) {'100k+'}
          let(:c2) {'true'}
          let(:e2) {'hispanic'}
          let(:el2) {'no_college'}

          context "When the third response has no data" do
            let(:g3) {}
            let(:a3) {}
            let(:i3) {}
            let(:c3) {}
            let(:e3) {}
            let(:el3) {}

            let!(:hash) {DemographicSummary.aggregate_data_for_question(question)}

            it {expect(hash['GENDER'][:buckets][0][:name]).to eq "Male"}
            it {expect(hash['GENDER'][:buckets][0][:percent]).to eq 1/2.0}
            it {expect(hash['GENDER'][:buckets][1][:name]).to eq "Female"}
            it {expect(hash['GENDER'][:buckets][1][:percent]).to eq 1/2.0}

            it {expect(hash['AGE'][:buckets][0][:name]).to eq "18-24"}
            it {expect(hash['AGE'][:buckets][0][:percent]).to eq 1/2.0}
            it {expect(hash['AGE'][:buckets][1][:name]).to eq "45-54"}
            it {expect(hash['AGE'][:buckets][1][:percent]).to eq 1/2.0}
            it {expect(hash['AGE'][:buckets][2][:name]).to eq "0-18"}
            it {expect(hash['AGE'][:buckets][2][:percent]).to eq 0.0}
            it {expect(hash['AGE'][:buckets][3][:name]).to eq "25-34"}
            it {expect(hash['AGE'][:buckets][3][:percent]).to eq 0.0}
            it {expect(hash['AGE'][:buckets][4][:name]).to eq "35-44"}
            it {expect(hash['AGE'][:buckets][4][:percent]).to eq 0.0}
            it {expect(hash['AGE'][:buckets][5][:name]).to eq "55+"}
            it {expect(hash['AGE'][:buckets][5][:percent]).to eq 0.0}

            it {expect(hash['CHILDREN'][:buckets][0][:name]).to eq "Has Kids"}
            it {expect(hash['CHILDREN'][:buckets][0][:percent]).to eq 1/2.0}
            it {expect(hash['CHILDREN'][:buckets][1][:name]).to eq "No Kids"}
            it {expect(hash['CHILDREN'][:buckets][1][:percent]).to eq 1/2.0}

            it {expect(hash['INCOME'][:buckets][0][:name]).to eq "$100k+"}
            it {expect(hash['INCOME'][:buckets][0][:percent]).to eq 1/2.0}
            it {expect(hash['INCOME'][:buckets][1][:name]).to eq "$0-100k"}
            it {expect(hash['INCOME'][:buckets][1][:percent]).to eq 1/2.0}

            it {expect(hash['EDUCATION'][:buckets][0][:name]).to eq "No College"}
            it {expect(hash['EDUCATION'][:buckets][0][:percent]).to eq 1/2.0}
            it {expect(hash['EDUCATION'][:buckets][1][:name]).to eq "College"}
            it {expect(hash['EDUCATION'][:buckets][1][:percent]).to eq 1/2.0}

            it {expect(hash['ETHNICITY'][:buckets][0][:name]).to eq "Asian"}
            it {expect(hash['ETHNICITY'][:buckets][0][:percent]).to eq 1/2.0}
            it {expect(hash['ETHNICITY'][:buckets][1][:name]).to eq "Hispanic"}
            it {expect(hash['ETHNICITY'][:buckets][1][:percent]).to eq 1/2.0}
            it {expect(hash['ETHNICITY'][:buckets][2][:name]).to eq "African American"}
            it {expect(hash['ETHNICITY'][:buckets][2][:percent]).to eq 0.0}
            it {expect(hash['ETHNICITY'][:buckets][3][:name]).to eq "Caucasian"}
            it {expect(hash['ETHNICITY'][:buckets][3][:percent]).to eq 0.0}

            it {expect(hash['AFFILIATION'][:buckets]).to be_empty}

            it {expect(hash['ENGAGEMENT'][:buckets]).to be_empty}
          end
        end
      end
    end
  end

  describe '.aggregate_data_for_choice' do
    let(:choice) { double('Choice') }

    it 'builds a demographics hash' do
      expect(DemographicSummary).to receive(:aggregate_data_for)
        .with(choice, {})
        .and_return(example: 'data')

      hash = DemographicSummary.aggregate_data_for_choice(choice)
      expect(hash).to eq({choice: choice, example: 'data'})
    end
  end

end
