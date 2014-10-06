require 'rails_helper'

describe GroupMember do
  let(:group) { FactoryGirl.create(:group) }
  let(:user) { FactoryGirl.create(:user) }
  subject { FactoryGirl.build(:group_member, group: group, user: user) }

  before { user.leaders << group.user }

  it { should be_valid }
end
