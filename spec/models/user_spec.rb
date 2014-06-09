require 'spec_helper'
require 'pp'

describe User do

  before do
    @user = User.new(username: "example_user", name: "Example User", email: "user@example.com", password: "foobar69", password_confirmation: "foobar69")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }
  it { should respond_to(:following?) }
  it { should respond_to(:follow!) }
  it { should respond_to(:unfollow!) }
  it { should respond_to(:ownerships) }
  it { should respond_to(:own!) }
  it { should respond_to(:disown!) }
  it { should respond_to(:owner_of?) }
  it { should respond_to(:username) }
  it { should respond_to(:questions) }
  it { should respond_to(:answers) }
  it { should respond_to(:packs) }
  it { should respond_to(:comments) }
  it { should respond_to(:friendships) }
  it { should respond_to(:friends) }
  it { should respond_to(:reverse_friendships) }
  it { should respond_to(:reverse_friends) }
  it { should respond_to(:friends_with?) }
  it { should respond_to(:friend!) }
  it { should respond_to(:unfriend!) }
  it { should respond_to(:sharings) }
  it { should respond_to(:reverse_sharings) }

  it { should be_valid }
  it { should_not be_admin }

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "when username is not present" do
    before { @user.username = " " }
    it { should_not be_valid }
  end

  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "when username is too long" do
    before { @user.username = "a" * 51 }
    it { should_not be_valid }
  end

  describe "when username format is invalid" do
    it "should be invalid" do
      usernames = %w[jazz$$$ 'tester' bananas99/&# hotsauce()]
      usernames.each do |invalid_username|
        @user.username = invalid_username
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when username format is valid" do
    it "should be valid" do
      usernames = %w[jason123456 123456789 _davidsmith joakim_noah jeff-mike_69]
      usernames.each do |valid_username|
        @user.username = valid_username
        expect(@user).to be_valid
      end
    end
  end

  describe "when username is already taken" do
    before do
      user_with_same_username = @user.dup
      user_with_same_username.username = @user.username.upcase
      user_with_same_username.email = "differentemail@test.com"
      user_with_same_username.save
    end

    it { should_not be_valid }
  end

  describe "username with mixed case" do
    let (:mixed_case_username) { "Funny_Guy-23X" }

    it "should be saved as all lower-case" do
      @user.username = mixed_case_username
      @user.save
      expect(@user.reload.username).to eq mixed_case_username.downcase
    end
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com foo@bar..com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.username = "differentusername"
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

    it "should be saved as all lower-case" do
      @user.email = mixed_case_email
      @user.save
      expect(@user.reload.email).to eq mixed_case_email.downcase
    end
  end

  describe "when password is not present" do
    before do
      @user = User.new(name: "Example User", email: "user@example.com",
                       password: " ", password_confirmation: " ")
    end
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 7 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  describe "micropost associations" do

    before { @user.save }
    let!(:older_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end

    it "should have the right microposts in the right order" do
      expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end

    it "should destroy associated microposts" do
      microposts = @user.microposts.to_a
      @user.destroy
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end

    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }

      before do
        @user.follow!(followed_user)
        3.times { followed_user.microposts.create!(content: "Lorem ipsum") }
      end

      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
      its(:feed) do
        followed_user.microposts.each do |micropost|
          should include(micropost)
        end
      end
    end
  end

  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow!(other_user)
    end

    it { should be_following(other_user) }
    its(:followed_users) { should include(other_user) }

    describe "followed user" do
      subject { other_user }
      its(:followers) { should include(@user) }
    end

    describe "and unfollowing" do
      before { @user.unfollow!(other_user) }

      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }
    end
  end

  describe "owning" do
    let (:device) { FactoryGirl.create(:device) }
    let (:another_device) { FactoryGirl.create(:device) }
    before do
      @user.save
      @user.own!(device)
      @user.own!(another_device)
    end

    specify { expect(@user).to be_owner_of(device) }
    its(:devices) { should include(device) }

    describe "owned device" do
      subject { device }
      its(:users) { should include(@user) }
    end

    describe "and disowning" do
      before { @user.disown!(device) }

      it { should_not be_owner_of(device) }
      its(:devices) { should_not include(device) }
    end

    it "should destroy associated ownerships" do
      ownerships = @user.ownerships.to_a
      @user.destroy
      expect(ownerships).not_to be_empty
      ownerships.each do |ownership|
        expect(Ownership.where(id: ownership.id)).to be_empty
      end
    end

  end

  describe "question associations" do
    before { @user.save }

    let!(:category) { FactoryGirl.create(:category) }
    let!(:question) { FactoryGirl.create(:question, user: @user, category: category) }
    let!(:another_question) { FactoryGirl.create(:question, user: @user, category: category) }
    let!(:other_user) { FactoryGirl.create(:user) }
    let!(:other_question) { FactoryGirl.create(:question, user: other_user, category: category) }

    its(:questions) { should include(question) }
    its(:questions) { should include(another_question) }
    its(:questions) { should_not include(other_question) }

    describe "a questions user" do
      subject { question }
      its(:user) { should eq @user }
    end

    it "should destroy associated questions" do
      questions = @user.questions.to_a
      @user.destroy
      expect(questions).not_to be_empty
      questions.each do |question|
        expect(Question.where(id: question.id)).to be_empty
      end
    end
  end

  describe "answer associations" do
    before { @user.save }

    let!(:category) { FactoryGirl.create(:category) }
    let!(:ask_user) { FactoryGirl.create(:user) }
    let!(:question) { FactoryGirl.create(:question, user: ask_user, category: category) }
    let!(:answer)  { FactoryGirl.create(:answer, user: @user, question: question) }
    let!(:other_answer) { FactoryGirl.create(:answer, user: ask_user, question: question) }
    let!(:another_question) { FactoryGirl.create(:question, user: @user, category: category) }
    let!(:another_answer) { FactoryGirl.create(:answer, user: @user, question: another_question) }

    its(:answers) { should include(answer) }
    its(:answers) { should include(another_answer) }
    its(:answers) { should_not include(other_answer) }

    describe "an answers user" do
      subject { answer }
      its(:user) { should eq @user }
    end

    describe "an answers question" do
      subject { answer }
      its(:question) { should eq question }
    end

    it "should destroy associated answers" do
      answers = @user.answers.to_a
      @user.destroy
      expect(answers).not_to be_empty
      answers.each do |answer|
        expect(Answer.where(id: answer.id)).to be_empty
      end
    end
  end

  describe "pack associations" do
    before { @user.save }

    let!(:pack) { FactoryGirl.create(:pack, user: @user) }
    let!(:another_pack) { FactoryGirl.create(:pack, user: @user) }
    let!(:other_user) { FactoryGirl.create(:user) }
    let!(:other_pack) { FactoryGirl.create(:pack, user: other_user) }
    
    its(:packs) { should include(pack) }
    its(:packs) { should include(another_pack) }
    its(:packs) { should_not include(other_pack) }

    describe "a packs users" do
      subject { pack }
      its(:user) { should eq @user }
      its(:user) { should_not eq other_user }
    end

    it "should destroy associated packs" do
      packs = @user.packs.to_a
      @user.destroy
      expect(packs).not_to be_empty
      packs.each do |pack|
        expect(Pack.where(id: pack.id)).to be_empty
      end
    end
  end

  describe "comment associations" do
    before { @user.save }

    let!(:question) { FactoryGirl.create(:question, user: @user) }
    let!(:other_user) { FactoryGirl.create(:user) }
    let!(:comment) { FactoryGirl.create(:comment, user: @user, question: question) }
    let!(:another_comment) { FactoryGirl.create(:comment, user: @user, question: question) }
    let!(:other_comment) { FactoryGirl.create(:comment, user: other_user, question: question) }

    its(:comments) { should include(comment) }
    its(:comments) { should include(another_comment) }
    its(:comments) { should_not include(other_comment) }

    describe "a comments users" do
      subject { comment }
      its(:user) { should eq @user }
      its(:user) { should_not eq other_user }
    end

    it "should destroy associated comments" do
      comments = @user.comments.to_a
      @user.destroy
      expect(comments).not_to be_empty
      comments.each do |comment|
        expect(Comment.where(id: comment.id)).to be_empty
      end
    end
  end

  describe "friending" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.friend!(other_user)
    end

    it { should be_friends_with(other_user) }
    its(:friends) { should include(other_user) }

    describe "friended user" do
      subject { other_user }
      its(:reverse_friends) { should include(@user) }
    end

    describe "and unfriending" do
      before { @user.unfriend!(other_user) }

      it { should_not be_friends_with(other_user) }
      its(:friends) { should_not include(other_user) }
    end
  end

  describe "sharing associations" do
    before { @user.save }

    let!(:question) { FactoryGirl.create(:question, user: @user) }
    let!(:other_user) { FactoryGirl.create(:user) }
    let!(:sharing) { FactoryGirl.create(:sharing, sender: @user, receiver: other_user, question: question) }
    let!(:reverse_sharing) { FactoryGirl.create(:sharing, sender: other_user, receiver: @user, question: question) }

    its(:sharings) { should include(sharing) }
    its(:sharings) { should_not include(reverse_sharing) }
    its(:reverse_sharings) { should include(reverse_sharing) }
    its(:reverse_sharings) { should_not include(sharing) }

    describe "a sharings users" do
      subject { sharing }
      its(:sender) { should eq @user }
      its(:receiver) { should eq other_user }
      its(:sender) { should_not eq other_user }
      its(:receiver) { should_not eq @user }
    end

    it "should destroy associated sharings" do
      sharings = @user.sharings.to_a
      @user.destroy
      expect(sharings).not_to be_empty
      sharings.each do |sharing|
        expect(Sharing.where(id: sharing.id)).to be_empty
      end
    end
  end


end