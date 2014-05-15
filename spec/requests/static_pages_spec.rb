require 'spec_helper'

describe "Static pages" do
	let(:base_title) {"RoR Tutorial App"}
	describe "Home page" do

		it "should have the content 'Sample App'" do
			visit '/static_pages/home'
			expect(page).to have_content('Sample App')
		end

		it "should have base page title" do
			visit '/static_pages/home'
			expect(page).to have_title(base_title)
		end

		it "should have the title 'Home'" do
			visit '/static_pages/home'
			expect(page).not_to have_title("Home")  			
		end
	end

	describe "Help page" do

	    it "should have the content 'Help'" do
	      visit '/static_pages/help'
	      expect(page).to have_content('Help')
	    end

	    it "should have title 'Help'" do
	    	visit '/static_pages/help'
	    	expect(page).to have_title("Help")
	    end
  end
	
	describe "About page" do
		it "should have content 'About us'" do
			visit '/static_pages/about'
			expect(page).to have_content('About Us')
		end	  	

		it "should have title 'About'" do
			visit '/static_pages/about'
			expect(page).to have_title("About") 			
		end
	end  

	describe "Contacts page" do
		it "should have content 'Contacts'" do
			visit '/static_pages/contacts'
			expect(page).to have_content("Contacts")
		end

		it "should have title 'Contacts'" do
			visit '/static_pages/contacts'
			expect(page).to have_title("Contacts")			
		end		
	end
end
