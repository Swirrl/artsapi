require "rails_helper"

describe "Viewing a resource" do

  it_behaves_like "given a db with two organisations" do
    before { visit '/id/people/jeff-widgetcorp-org' }

    context "resource page for a Person" do

      it { expect(page).to have_content("Viewing #{jeff.human_name}") }

      it { expect(page).to have_content("Graph") }
      it { expect(page).to have_content("Distribution") }
      it { expect(page).to have_content("Connections") }
      it { expect(page).to have_content("Keywords") }
      it { expect(page).to have_content("Data") }

      it { expect(page).to have_content("3 Emails sent") }
    end

    context "resource page for an Organisation" do

      before do
        jeff.get_connections!
        visit '/id/organisations/widgetcorp-org'
      end

      it "should use the label" do
        expect(page).to have_content('Viewing widgetcorp.org')
      end

      it { expect(page).to have_content("Graph") }
      it { expect(page).to have_content("Members") }
      it { expect(page).to have_content("Links") }
      it { expect(page).to have_content("Data") }

      it { expect(page).to have_content("2 Members") }
      it { expect(page).to have_content("1 Linked Organisation") }
      it { expect(page).to have_content("Jeff") }
    end

    context "resource page for an Email" do
      before do
        path = URI(email.uri).path
        visit path
      end

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