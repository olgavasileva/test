require 'rails_helper'

describe Question do

  it { is_expected.to have_one(:questions_survey).dependent(:destroy) }

  describe 'validation' do
    it { is_expected.to allow_value(nil).for(:category_id) }

    it { is_expected.to allow_value(FactoryGirl.create(:category).id)
          .for(:category_id) }

    it { is_expected.to_not allow_value(787878).for(:category_id)
          .with_message(/does not exist/, against: :base) }

    context 'when creating' do
      let(:question) { Question.new }

      it 'forces rotate to true' do
        question.rotate = false
        question.valid?
        expect(question.rotate).to eq(true)
      end
    end

    context 'for survey_id' do
      let(:user) { FactoryGirl.create(:user) }
      let(:survey_user) { user }
      let(:survey) { FactoryGirl.create(:survey, user: survey_user) }

      subject { Question.new(user: user) }

      context 'when the survey does not exists' do
        it { is_expected.to_not allow_value(99999).for(:survey_id)
              .with_message(/Survey does not exist/, against: :base) }
      end

      context 'when the user owns the survey' do
        it { is_expected.to allow_value(survey.id).for(:survey_id) }
      end

      context 'when the user does not own the survey' do
        let(:survey_user) { FactoryGirl.create(:user) }
        it { is_expected.to_not allow_value(survey.id).for(:survey_id)
              .with_message(/is unauthorized for this user/) }
      end
    end
  end

  describe 'creating' do
    context 'when a valid :survey_id is present' do
      let!(:user) { FactoryGirl.create(:user) }
      let!(:survey)  { FactoryGirl.create(:survey, user: user) }
      let(:position) { nil }

      before do
        survey.questions << FactoryGirl.create_list(:text_question, 2, user: user)
      end

      let(:question) do
        FactoryGirl.build(:question, {
          user: user,
          survey_id: survey.id,
          survey_position: position
        })
      end

      it 'creates a QuestionsSurvey record' do
        expect{question.save!}.to change(QuestionsSurvey, :count).by(1)
        expect(question.questions_survey).to be_present
      end

      context 'given a survey_position' do
        let(:position) { 2 }
        it 'sets the position' do
          question.save!
          expect(question.questions_survey.position).to eq(position)
        end
      end
    end
  end

  describe :image_question do
    let(:q) {FactoryGirl.build :image_question}

    it {expect(q).to be_valid}
    it {q.responses.build.class.should eq ImageResponse}
  end

  describe :text_question do
    let(:q) {FactoryGirl.build :text_question}

    it {q.should be_valid}
    it {q.responses.build.class.should eq TextResponse}
  end

  describe :choice_question do
    let(:q) { FactoryGirl.create :choice_question }
  end

  describe :text_choice_question do
    let(:q) {FactoryGirl.build :text_choice_question}

    it {q.should be_valid}
    it {q.responses.build.class.should eq TextChoiceResponse}
  end

  describe :multiple_choice_question do
    let(:q) {FactoryGirl.build :multiple_choice_question}

    it {q.should be_valid}
    it {q.responses.build.class.should eq MultipleChoiceResponse}
  end

  describe :star_question do
    let(:q) {FactoryGirl.build :star_question}

    it {q.should be_valid}
    it {q.responses.build.class.should eq StarResponse}
  end

  describe :percent_question do
    let(:q) {FactoryGirl.build :percent_question}

    it {q.should be_valid}
    it {q.responses.build.class.should eq PercentResponse}
  end

  describe :order_question do
    let(:q) {FactoryGirl.build :order_question}

    it {q.should be_valid}
    it {expect(q.responses.build.class).to eq OrderResponse}
  end

  describe :notifiable? do
    let(:notifying) { false }
    subject { Question.new(notifying: notifying).notifiable? }

    context 'when notifying is true' do
      let(:notifying) { true }
      it { is_expected.to eq(false) }
    end

    context 'when notifying is false' do
      it { is_expected.to eq(true) }
    end
  end

  describe :choice_result_cache do
    subject { Question.new.choice_result_cache }
    it { is_expected.to be_a(ChoiceResultCache) }
  end

  describe '#ordered_choices_for' do
    it 'delegates to QuestionChoiceOrderer correctly' do
      question = Question.new
      user = User.new

      orderer = question.ordered_choices_for(user)
      expect(orderer).to be_a(QuestionChoiceOrderer)
      expect(orderer.question).to eq(question)
      expect(orderer.reader).to eq(user)
    end
  end

  describe :refresh_recent_responses_count! do
    context "With 5 questions" do
      before { @qq = FactoryGirl.create_list :question, 5 }
      let(:qq) { @qq }

      it "All questions should have no responses" do
        Question.refresh_recent_responses_count!
        expect(Question.where(recent_responses_count: 0).count).to eq qq.count
      end

      context "When the first quesiton has 5 responses, one in each of the last 5 days" do
        before { (1..5).to_a.each{|n| FactoryGirl.create :response, question: @qq[0], created_at: Time.current - n.days + 15.minutes } }

        it "Before refresing, the first question's recent_responses_count should be 5" do
          expect(qq[0].reload.recent_responses_count).to eq 5
        end

        it "The first question should have 5 responses within 5 days" do
          Question.refresh_recent_responses_count! 5
          expect(qq[0].reload.recent_responses_count).to eq 5
        end

        it "The first question should have 4 responses within 4 days" do
          Question.refresh_recent_responses_count! 4
          expect(qq[0].reload.recent_responses_count).to eq 4
        end

        it "The other questions should have no responses within 5 days" do
          Question.refresh_recent_responses_count! 5
          expect(Question.where(recent_responses_count: 0).count).to eq 4
        end

        context "When the last question has 1 response 7 days ago" do
          before { FactoryGirl.create :response, question: @qq[4], created_at: Time.current - 7.days }
          before { Question.refresh_recent_responses_count! 14 }

          it "The first question should have 5 responses within 14 days" do
            expect(qq[0].reload.recent_responses_count).to eq 5
          end

          it "The last quesiton should have 1 response withing 14 days" do
            expect(qq[4].reload.recent_responses_count).to eq 1
          end
        end
      end
    end
  end

  describe :deployment_count do
    context "When unique_referrers has some data" do
      let(:q) {FactoryGirl.create :question}
      let(:unique_referrers) {
        ["http://site1.com/qp/10",
        "http://site1.com/qp/11",
        "http://site2.com/qp/10",
        "http://site2.com/qp/11",
        "http://foo.site2.com/qp/10",
        "http://bar.site2.com/qp/11",
        "http://site3.com/qp/10",
        "http://site3.com/qp/10",
        "/qp/20",
        "/qp/30",
        "foo.com/qp/40",
        "bar.com/qp/50"]
      }
      before {expect(q).to receive(:unique_referrers).and_return(unique_referrers)}

      it {expect(q.deployment_count).to eq 6}

      context "When there are no referrers" do
        let(:unique_referrers) {[]}

        it {expect(q.deployment_count).to eq 0}
      end
    end
  end

  describe :unique_deployments do
    context "When unique_referrers has some data" do
      let(:q) {FactoryGirl.create :question}
      let(:unique_referrers) {
        ["http://site1.com/qp/10",
        "http://site1.com/qp/11",
        "http://site2.com/qp/10",
        "http://site2.com/qp/11",
        "http://foo.site2.com/qp/10",
        "http://bar.site2.com/qp/11",
        "http://site3.com/qp/10",
        "http://site3.com/qp/10",
        "/qp/20",
        "/qp/30",
        "foo.com/qp/40",
        "bar.com/qp/50"]
      }
      before {expect(q).to receive(:unique_referrers).and_return(unique_referrers)}

      it {expect(q.unique_deployments).to match_array %w(site1.com site2.com foo.site2.com bar.site2.com site3.com) + [true]}

      context "When there are no referrers" do
        let(:unique_referrers) {[]}

        it {expect(q.unique_deployments).to eq []}
      end
    end
  end

  describe :complete_rate do
    let(:q) {FactoryGirl.create :question}
    before {allow(q).to receive(:response_count).and_return(response_count)}
    before {allow(q).to receive(:view_count).and_return(view_count)}

    context "With valid response and view counts" do
      let(:response_count) {10}
      let(:view_count) {20}

      it {expect(q.complete_rate).to eq 0.5}

      context "With 0 for the response count" do
        let(:response_count) {0}
        it {expect(q.complete_rate).to eq 0.0}
      end

      context "With 0 for the view count" do
        let(:view_count) {0}
        it {expect(q.complete_rate).to be_nil}
      end

      context "With 0 for the view and response counts" do
        let(:response_count) {0}
        let(:view_count) {0}
        it {expect(q.complete_rate).to eq 0.0}
      end
    end

  end
end
