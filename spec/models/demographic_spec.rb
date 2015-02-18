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

    context "With a question and 3 responses" do
      let(:question) {FactoryGirl.create :question}
      let(:r1) {FactoryGirl.create :response, question:question }
      let(:r2) {FactoryGirl.create :response, question:question }
      let(:r3) {FactoryGirl.create :response, question:question }

      let!(:d1) {FactoryGirl.create :demographic, respondent:r1.user, gender:g1, age_range:a1, household_income:i1, children:c1, ethnicity:e1, education_level:el1}
      let!(:d2) {FactoryGirl.create :demographic, respondent:r2.user, gender:g2, age_range:a2, household_income:i2, children:c2, ethnicity:e2, education_level:el2}
      let!(:d3) {FactoryGirl.create :demographic, respondent:r3.user, gender:g3, age_range:a3, household_income:i3, children:c3, ethnicity:e3, education_level:el3}

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
        let!(:hash) {Demographic.aggregate_data_for_question(question)}

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

            it 'builds the correct hash' do
              hash = Demographic.aggregate_data_for_question(question)

              expect(hash).to eq(
              {
                question: question,

                "GENDER" =>  {
                  id: "GENDER",
                  name: "Gender",
                  buckets:  [
                    {name: "Male", index: 101.9607843137255, percent: 0.5},
                    {name: "Female", index: 98.0392156862745, percent: 0.5}
                  ],
                  largest_bucket: {name: "Male", index: 101.9607843137255, percent: 0.5}
                },

                "AGE" => {
                  id: "AGE",
                  name: "Age",
                  buckets: [
                    {name: "< 18", index: 0.0, percent: 0.0},
                    {name: "18-24", index: 143.1818181818182, percent: 0.5},
                    {name: "25-34", index: 0.0, percent: 0.0},
                    {name: "35-44", index: 0.0, percent: 0.0},
                    {name: "45-54", index: 139.75903614457832, percent: 0.5},
                    {name: "55+", index: 0.0, percent: 0.0}
                  ],
                  largest_bucket: {name: "18-24", index: 143.1818181818182, percent: 0.5}
                },

                "CHILDREN" => {
                  id: "CHILDREN",
                  name: "Children in Household",
                  buckets: [
                    {name: "Has Kids", index: 100.0, percent: 0.5},
                    {name: "No Kids", index: 100.0, percent: 0.5}
                  ],
                  largest_bucket: {name: "No Kids", index: 100.0, percent: 0.5}
                },

                "INCOME" => {
                  id: "INCOME",
                  name: "Household Income",
                  buckets: [
                    {name: "$0-$100k", index: 62.5, percent: 0.5},
                    {name: "$100k+", index: 137.5, percent: 0.5}
                  ],
                  largest_bucket: {name: "$100k+", index: 137.5, percent: 0.5}
                },

                "EDUCATION" => {
                  id: "EDUCATION",
                  name: "Education Level",
                  buckets: [
                    {name: "College", index: 90.9090909090909, percent: 0.5},
                    {name: "No College", index: 109.0909090909091, percent: 0.5}
                  ],
                  largest_bucket: {name: "No College", index: 109.0909090909091, percent: 0.5}
                },

                "ETHNICITY" => {
                  id: "ETHNICITY",
                  name: "Ethnicity",
                  buckets: [
                    {name: "Hispanic", index: 145.05494505494505, percent: 0.5},
                    {name: "Asian", index: 147.91666666666669, percent: 0.5},
                    {name: "African American", index: 0.0, percent: 0.0},
                    {name: "Caucasian", index: 0.0, percent: 0.0}
                  ],
                  largest_bucket: {name: "Asian", index: 147.91666666666669, percent: 0.5}
                },

                "AFFILIATION" => {
                  id: "AFFILIATION",
                  name: "Political Affiliation",
                  buckets: [],
                  largest_bucket: nil
                },

                "ENGAGEMENT" => {
                  id: "ENGAGEMENT",
                  name: "Political Engagement",
                  buckets: [],
                  largest_bucket: nil
                }
              })
            end
          end
        end
      end
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
