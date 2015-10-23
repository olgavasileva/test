require 'rails_helper'

describe ListicleQuestion, :type => :model do
  before :each do
    @listicle = FactoryGirl.create :listicle
    @listicle_question = FactoryGirl.build :listicle_question
    @listicle_question.listicle = @listicle
    @listicle_question.save
  end

  describe 'responses' do
    before :each do
      @user1 = FactoryGirl.build :user
      @user2 = FactoryGirl.build :user
    end

    it 'counts votes of one user' do
      make_vote(@user1, true)
      expect(@listicle_question.score).to eq 1

      make_vote(@user1, true)
      expect(@listicle_question.score).to eq 1

      make_vote(@user1, false)
      expect(@listicle_question.score).to eq 0

      make_vote(@user1, false)
      expect(@listicle_question.score).to eq -1

      make_vote(@user1, false)
      expect(@listicle_question.score).to eq -1

      make_vote(@user1, true)
      expect(@listicle_question.score).to eq 0
    end

    it 'counts votes from 2+ users' do
      make_vote(@user1, true)
      expect(@listicle_question.score).to eq 1

      make_vote(@user2, true)
      expect(@listicle_question.score).to eq 2

      make_vote(@user1, false)
      expect(@listicle_question.score).to eq 1

      make_vote(@user1, false)
      expect(@listicle_question.score).to eq 0

      make_vote(@user1, false)
      expect(@listicle_question.score).to eq 0

      make_vote(@user2, false)
      expect(@listicle_question.score).to eq -1

      make_vote(@user2, false)
      expect(@listicle_question.score).to eq -2

      make_vote(@user2, true)
      expect(@listicle_question.score).to eq -1

      make_vote(@user2, true)
      expect(@listicle_question.score).to eq 0
    end
  end

  def make_vote(user, is_up)
    ListicleResponse.create(user: user, is_up: is_up, question: @listicle_question)
  end
end
