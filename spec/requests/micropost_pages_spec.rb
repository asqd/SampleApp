require 'spec_helper'

describe "MicropostPages" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { valid_signin user }

  describe "micropost creation" do
    before { visit root_path }

    describe "with invalid information" do
      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end

      describe "error messages" do
        before { click_button "Post" }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do
      before { fill_in 'micropost_content', with: "The Song Remains The Same" }
      it "should create a micropost" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end
    end

  end

  describe "pagination microposts" do
    before do      
      40.times { FactoryGirl.create(:micropost, user: user) }
      
      visit user_path(user)
    end
    after do
      Micropost.delete_all
      User.delete_all
    end

    it { should have_selector('div.pagination') }

    it "sould list each micropost" do
      user.microposts.paginate(page: 1).each do |micropost|
        expect(page).to have_selector("li", text: micropost.content) 
      end
    end
  end

  describe "micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link "delete"}.to change(Micropost, :count).by(-1)
      end
    end
  end

end
