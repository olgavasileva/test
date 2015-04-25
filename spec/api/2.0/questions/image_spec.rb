require 'rails_helper'

RSpec.describe TwoCents::Questions, '/image' do
  before do
    @instance = FactoryGirl.create(:instance, :logged_in)
    @ad_unit = FactoryGirl.create(:ad_unit, name: 'skyscraper')
    @question = FactoryGirl.create(:text_choice_question, user: @instance.user)
  end

  let(:token) { @instance.auth_token }
  let(:image) { @question.background_image}

  describe 'PUT /image' do
    subject do
      put 'v/2.0/questions/image', {
        auth_token: token,
        image_id: image.id,
        meta_data: {skyscraper: {scale: 1}}
      }
    end

    it 'returns the data for the image' do
      subject
      expect(json['image']).to be_present
    end
  end
end
