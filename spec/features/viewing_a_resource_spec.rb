require "rails_helper"

describe "Viewing a resource" do

  it_behaves_like "given a db with two organisations" do

    # mock a signed-in user for DB queries
    # before { User.current_user = user }

    describe "when not signed in" do

      before { visit '/id/people/jeff-widgetcorp-org' }

      context "resource page for a Person" do

        it "should prompt to log in" do
          expect(page).to have_content("You need to sign in or sign up before continuing. Log in Email Password Remember me Forgot your password?")
        end

        it "login page should not prompt to sign up" do
          expect(page).not_to have_link("Sign up")
        end

      end

      context "resource page for an Organisation" do

        before do
          visit '/id/organisations/widgetcorp-org'
        end

        it "should prompt to log in" do
          expect(page).to have_content("You need to sign in or sign up before continuing. Log in Email Password Remember me Forgot your password?")
        end

      end

      context "resource page for an Email" do
        before do
          path = URI(email.uri).path
          visit path
        end

        it "should prompt to log in" do
          expect(page).to have_content("You need to sign in or sign up before continuing. Log in Email Password Remember me Forgot your password?")
        end
      end

      context "an invalid uri" do
        before { visit '/id/people/darth-vader' }

        it "should prompt to log in" do
          expect(page).to have_content("You need to sign in or sign up before continuing. Log in Email Password Remember me Forgot your password?")
        end
      end

      context "visiting the root" do
        before { visit root_path }

        it "should prompt to log in" do
          expect(page).to have_content("Log in Email Password Remember me Forgot your password?")
        end
      end

      context "visiting the home page" do
        before { visit home_path }

        it "should prompt to log in" do
          expect(page).to have_content("You need to sign in or sign up before continuing. Log in Email Password Remember me Forgot your password?")
        end
      end

      context "visiting the about page" do
        before { visit about_path }

        it { expect(page).to have_content("About") }
      end

      context "visiting the contact page" do
        before { visit contact_path }

        it { expect(page).to have_content("Contact") }
      end

    end

    describe "when signed in" do

      context "resource page for a Person" do

        before do
          AuthHelpers.sign_in user
          visit '/id/people/jeff-widgetcorp-org'
        end

        it { expect(page).to have_content("Jeff Lebowsk") }

        it { expect(page).to have_content("Graph") }
        it { expect(page).to have_content("Distribution") }
        it { expect(page).to have_content("Connections") }
        it { expect(page).to have_content("Keywords") }
        it { expect(page).to have_content("Data") }

        it { expect(page).to have_content("3 Emails sent") }
      end

      context "resource page for an Organisation" do

        before do
          AuthHelpers.sign_in user
          sleep 0.1
          jeff.get_connections!
          visit '/id/organisations/widgetcorp-org'
        end

        it "should use the label" do
          expect(page).to have_content('widgetcorp.org')
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
          AuthHelpers.sign_in user
          path = URI(email.uri).path
          visit path
        end

        it "should still render the page" do
          expect(page).to have_content('Resource')
        end
      end

      context "an invalid uri" do
        before do
          AuthHelpers.sign_in user
          visit '/id/people/darth-vader'
        end

        it "should 404" do
          expect(page).to have_content('404')
        end
      end

    end

  end

end