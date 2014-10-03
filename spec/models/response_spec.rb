require 'rails_helper'

describe Response do
  it {expect(FactoryGirl.build(:image_response)).to be_valid}
  it {expect(FactoryGirl.build(:text_response)).to be_valid}
  it {expect(FactoryGirl.build(:multiple_choice_response)).to be_valid}
  it {expect(FactoryGirl.build(:text_choice_response)).to be_valid}
  it {expect(FactoryGirl.build(:order_response)).to be_valid}

  describe :comment_children do
    it "is responses whose comment parent is self" do
      q = FactoryGirl.create(:question)
      r1 = FactoryGirl.create(:response, question_id: q.id)
      r2 = FactoryGirl.create(:response, question_id: q.id)

      expect(r1.comment_children).to eq [r2]
    end
  end
end
