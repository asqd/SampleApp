require 'spec_helper'

describe "Static pages" do
	
	subject { page } 

	describe "Home page" do
		before { visit root_path }

		it { should have_content('Sample App') }
		it { should have_title(full_title('App')) }				
	end

	describe "Help page" do
		before { visit help_path }

	    it { should have_content('Help') }
	    it { should have_title(full_title('Help')) }
  	end
	
	describe "About page" do
		before { visit about_path }

		it { should have_content('About') }
	    it { should have_title(full_title('About')) }
	end
	 

	describe "Contacts page" do
		before { visit contacts_path }

		it { should have_content('Contacts') }
	    it { should have_title(full_title('Contacts')) }
	end
end
