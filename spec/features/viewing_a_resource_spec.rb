require "rails_helper"

describe "Viewing a resource" do

  it_behaves_like "given a db with two organisations" do
    before { visit '/id/people/jeff-widgetcorp-org' }

    context "resource page for a Person" do
      it { expect(page).to have_content("Viewing #{jeff.human_name}") }
    end

    context "resource page for an Organisation" do
      before { visit '/id/organisations/widgetcorp-org' }

      it "should use the label" do
        expect(page).to have_content('Viewing widgetcorp.org')
      end
    end

    context "resource page for an Email" do
      before { visit '/id/emails/email-1' }

      it "should still render the page" do
        expect(page).to have_content('Viewing Resource')
      end
    end

    context "an invalid uri" do
      before { visit '/id/people/darth-vader' }

      it "should 404" do
        expect(page).to have_content('404')
      end
    end

  end

end