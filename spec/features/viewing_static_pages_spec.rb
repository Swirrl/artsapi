require "rails_helper"

describe "static pages" do
  
  context "about page" do
    before { visit '/about' }

    it { expect(page).to have_content "About" }
  end

  context "contact page" do
    before { visit '/contact' }

    it { expect(page).to have_content "Contact" }
  end

end