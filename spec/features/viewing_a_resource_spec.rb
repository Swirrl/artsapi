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

      before { AuthHelpers.sign_in user }

      context "resource page for a Person" do

        before do
          visit '/id/people/jeff-widgetcorp-org'
        end

        it { expect(page).to have_content("Jeff Lebowsk") }

        it { expect(page).to have_content("Graph") }
        it { expect(page).to have_content("Distribution") }
        it { expect(page).to have_content("Connections") }
        it { expect(page).to have_content("Keywords") }
        it { expect(page).to have_content("Data") }
        it { expect(page).to have_content("Analysis") }

        it { expect(page).to have_content("3 Emails sent") }
      end

      context "resource page for an Organisation" do

        before do
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
        it { expect(page).to have_content("Analysis") }
        it { expect(page).to have_content("Clustering") }

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
          expect(page).to have_content('Resource')
        end
      end

      context "an invalid uri" do
        before do
          visit '/id/people/darth-vader'
        end

        it "should 404" do
          expect(page).to have_content('404')
        end
      end

      context "authorization page" do
        before { visit uploads_path }
        it { expect(page).to have_content('Authorize') }
        it { expect(page).to have_content('Dropbox') }
      end

      context "uploads page" do
        before do
          user.dropbox_auth_token = 'foo'
          user.save
          visit uploads_path
        end

        it { expect(page).to have_content('Upload Data to ArtsAPI') }
        it { expect(page).to have_content('mbox') }
        it { expect(page).to have_content('Please provide the path to the file you wish to upload.') }
        it { expect(page).to have_link('← Return home while upload completes') }
      end

      context "bulk markup screen for organisation" do
         before { visit collection_tagging_path(type: 'organisation') }
         it { expect(page).to have_content('Use this screen to tag these 2 Organisations with a human-readable label') }

        #  describe "filling in the field", js: true do
        #   before { within('.organisation-update-form:first') do
        #     fill_in :label, with: 'Widget Corp, Inc.'
        #     fill_in :city, with: 'Mos Eisley'
        #     click_button :submit
        #   end }

        #   it { expect(page).not_to have_content('widgetcorp-org') }
        #   it { expect(organisation.label).to eq "Widget Corp, Inc." }
        #   it { expect(organisation.city).to eq "Mos Eisley" }
        # end
      end


      context "bulk markup screen for person" do
        before { visit collection_tagging_path(type: 'person') }
        it { expect(page).to have_content('Use this screen to tag these 3 People with a human-readable label') }

        # describe "filling in the field", js: true do
        #   before { within('.person-update-form:first') do
        #     fill_in :label, with: 'Brian Vader'
        #     fill_in :position, with: 'A very naughty little sith'
        #     click_button :submit
        #   end }

        #   it { expect(page).not_to have_content('jeff@widgetcorp.org') }
        #   it { expect(jeff.human_name).to eq "Brian Vader" }
        #   it { expect(jeff.label).to eq "Brian Vader" }
        #   it { expect(jeff.position).to eq "A very naughty little sith" }
        # end
      end

    end

  end

end