require 'spec_helper'

describe User do
  before { @user = User.new(name: "example user", email: "user@example.com",
                            password: "foobar", password_confirmation: "foobar") }
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
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:following?) }
  it { should respond_to(:follow!) }

  it { should be_valid }
  it { should_not be_admin }

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end
    it { should be_admin }
  end

  #Name's tests
  describe "when the name is not present" do
    before { @user.name = " " }
    it { should_not be_valid}
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "when name is too short" do
    before { @user.name = "ab" }
    it { should_not be_valid }
  end

  #Email's tests
  describe "when the email is not present" do
    before { @user.email = " " }
    it { should_not be_valid}
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
      user_with_same_address = @user.dup
      user_with_same_address.email = @user.email.upcase
      user_with_same_address.save
    end

    it { should_not be_valid }
  end

  describe "email adress with mixed case" do
    let(:mixed_case_email) { "EmAiL@eXaMpLe.CoM" }
    it "should be saved as all lower-case" do
      @user.email = mixed_case_email
      @user.save
      expect(@user.reload.email).to eq mixed_case_email.downcase
    end
  end
  #Password's tests
  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " "}
    it { should_not be_valid }
  end

  describe "when password doesn't not match confirmation" do
    before { @user.password_confirmation = "mismatch"}
  end

  describe "when password too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  #Authenticate test's
  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }


    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe "with invaid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end
  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  #User's microposts
  describe "micropost associations" do
    before { @user.save }

    let!(:older_micropost) { FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago) }
    let!(:newer_micropost) { FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago) }

    it "should have the right microposts in right order" do
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
      let(:unfollowed_post) { FactoryGirl.create(:micropost, user: FactoryGirl.create(:user)) }
      let(:followed_user) { FactoryGirl.create(:user) } 

      before do
        @user.follow!(followed_user)
        3.times { followed_user.microposts.create!(content: "Knock-Knock!") }
      end

      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
      its(:feed) do
        followed_user.microposts.each { |micropost| should include(micropost) }
      end
    end
  end
  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow!(other_user)
    end

    describe "followed user" do
      subject { other_user } 
      its(:followers) { should include(@user) }
    end

    it { should be_following(other_user) }
    its(:followed_users) { should include(other_user) }

    describe "and unfollowing" do
      before { @user.unfollow!(other_user) }

      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }
    end


    describe "destroy follower user" do
      it "should destroy relationships" do
        @user.destroy
        expect(Relationship.where(follower_id: @user.id, followed_id: other_user.id)).to be_empty
      end
    end

    describe "destroy followed user" do
      it "should destroy relationships" do
        other_user.destroy
        expect(Relationship.where(follower_id: @user.id, followed_id: other_user.id)).to be_empty
      end
    end

  end
end
