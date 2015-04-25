require 'rails_helper'

describe BuildRespondentFeed do
  describe :perform do
    let(:respondent_id) {123}
    let(:num_questions_to_add) {5}

    context "When a respondent exists with respondent_id" do
      let(:respondent) {instance_double "Respondent", present?: true, needs_more_feed_items?: true}

      it "appends questions to the feed" do
        expect(Respondent).to receive(:find_by).and_return(respondent)
        expect(respondent).to receive(:append_questions_to_feed!).with(num_questions_to_add)

        BuildRespondentFeed.perform respondent_id, num_questions_to_add
      end
    end
  end
end
