require 'spec_helper'

describe "UserPages" do
  subject { page }

  describe "index" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      valid_signin FactoryGirl.create(:user)
      visit users_path
    end

    it { should have_title('All users') }
    it { should have_content('All users') }

    describe "pagination" do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all) { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    describe "delete microposts to current user only" do

      let(:other_user) { FactoryGirl.create(:user) }
      let!(:other_micropost) { FactoryGirl.create(:micropost, user: other_user) }

      before do
        visit user_path(other_user)
      end

      describe "no delete links" do
        it { should_not have_link('delete') }
      end

    end

    describe "delete links" do
      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          click_link('Sign out', href: signout_path)
          valid_signin admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end

  end

  describe "signup page" do
    before { visit signup_path }

    let(:submit) { "Create my account"}

    it { should have_content('Sign Up')}
    it { should have_title(full_title('Sign Up'))}

    describe "with invalid information" do
      it "should not create user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }

        it { should have_title('Sign Up') }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do
      before { valid_user }

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving user" do
        before { click_button submit }
        let(:user) { User.find_by(email: "user@example.com")}

        it { should have_link('Sign out') }
        it { should have_title(user.name) }
        it { should have_success_message('Welcome') }

      end
    end
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "First!") }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "Second!") }
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }

    describe "microposts" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end

    describe "follow/unfollow buttons" do
      let(:other_user) { FactoryGirl.create(:user) }
      before { valid_signin user }

      describe "following a user" do
        before { visit user_path(other_user) }
        it "shoul increment the followed user counts" do
          expect{ click_button "Follow" }.to change(user.followed_users, :count).by(1)
        end
        it "should increment the other user's followers count" do
          expect{ click_button "Follow" }.to change(other_user.followers, :count).by(1)
        end

        describe "toggling the button" do
          before { click_button "Follow" }
          it { should have_xpath("//input[@value='Unfollow']") }
        end
      end
      describe "unfollowing a user" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end
        it "should decrement the followed user count" do
          expect{ click_button "Unfollow" }.to change(user.followed_users, :count).by(-1)
        end

        it "should decrement the other user's ollowers count" do
          expect{ click_button "Unfollow" }.to change(other_user.followers, :count).by(-1)
        end

        describe "toggling the button" do
          before { click_button "Unfollow" }
          it { should have_xpath("//input[@value='Follow']") }
        end

      end
    end



    describe "edit" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        valid_signin user
        visit edit_user_path(user)
      end

      describe "page" do
        it { should have_content("Update your profile") }
        it { should have_title('Edit user') }
        it { should have_link('change', href: 'http://gravatar.com/emails') }
      end

      describe "with valid information" do
        let(:new_name) { "New Name" }
        let(:new_email) { "new@example.com" }

        before do
          fill_in "Name",  with: new_name
          fill_in "Email",  with: new_email
          fill_in "Password",  with: user.password
          fill_in "Confirmation",  with: user.password
          click_button "Save changes"
        end

        it { should have_title(new_name) }
        it { should have_success_message }
        it { should have_link('Sign out', href: signout_path) }
        specify { expect(user.reload.name).to eq new_name }
        specify { expect(user.reload.email).to eq new_email }

      end

      describe "with invalid information" do
        before { click_button "Save changes" }

        it { should have_content('error') }
      end

      describe "forbidden attributes" do
        let(:params) do
          { user: { admin: true, password: user.password,
                    password_confirmation: user.password } }
        end

        before do
          valid_signin user, no_capybara: true
          patch user_path(user), params
        end
        specify { expect(user.reload).not_to be_admin }
      end
    end

    describe "following/followers" do
      let(:user) { FactoryGirl.create(:user) }
      let(:other_user) { FactoryGirl.create(:user) }
      before { user.follow!(other_user) }

      describe "followed users" do
        before do
          valid_signin user
          visit following_user_path(user)
        end
        it { should have_title(full_title('Following')) }
        it { should have_selector('h3', text: 'Following') }
        it { should have_link(other_user.name, href: user_path(other_user)) }
      end

      describe "followers" do
        before do
          valid_signin user
          visit followers_user_path(other_user)
        end
        it { should have_title(full_title('Followers')) }
        it { should have_selector('h3', text: 'Followers') }
        it { should have_link(user.name, href: user_path(user)) }
      end
    end

  end

end
