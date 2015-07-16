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

  context "home page" do

    it_behaves_like "given a db with two organisations" do

      context "when not signed in" do

        before { visit root_path }

        it { expect(page).to have_content("Log in") }
        it { expect(page).to have_content("Email") }
        it { expect(page).to have_content("Password") }
        it { expect(page).to have_content("Forgot your password?") }

      end

      context "when signed in" do

        # mock a signed-in user for DB queries
        # before { User.current_user = user }

        before do 
          AuthHelpers.sign_in user
          visit root_path
        end

        it { expect(page).to have_content("Home") }
        it { expect(page).to have_content("Welcome to ArtsAPI: Getting Started") }
        it { expect(page).to have_content("Signed in as jeff@widgetcorp.org") }

        describe "process all button", js: true do

          before { visit root_path }

          it { expect(page).to have_css('.process-all-button') }
        end

        describe "clicking process-all-button", js: true do
          before do
            visit root_path
            find('.process-all-button').click
          end

          it do
            sleep 2
            user.reload
            expect(user.last_clicked_process_data_button).not_to be_nil
            expect(user.last_clicked_process_data_button).to be > (DateTime.now - 24.hours)

            visit current_path

            expect(page).to have_css('.process-all-button.disabled')
          end
        end

        describe "searching for a Person by email" do

          before do
            fill_in :search, with: "jeff@widgetcorp.org"
            click_button 'Search'
          end

          it { expect(page).to have_content(jeff.name.first) }
          it { expect(page).to have_content("Graph") }
          it { expect(page).to have_content("Distribution") }
          it { expect(page).to have_content("Connections") }
          it { expect(page).to have_content("Keywords") }
          it { expect(page).to have_content("Data") }

          it { expect(page).to have_content("3 Emails sent") }

        end
        
        describe "searching for a Person by name" do

          before do
            fill_in :search, with: jeff.name.first
            click_button 'Search'
          end

          it { expect(page).to have_content(jeff.name.first) }
          it { expect(page).to have_content("Graph") }
          it { expect(page).to have_content("Distribution") }
          it { expect(page).to have_content("Connections") }
          it { expect(page).to have_content("Keywords") }
          it { expect(page).to have_content("Data") }

          it { expect(page).to have_content("3 Emails sent") }

        end

        describe "searching for a non-existent or resource in another db" do

          before do
            fill_in :search, with: "jazz@swirrl.com"
            click_button 'Search'
          end

          it { expect(page).to have_content("Home") }
          it { expect(page).to have_content("Welcome to ArtsAPI: Getting Started") }
          it { expect(page).to have_content("Sorry, that resource couldn't be found.") }

        end

      end

    end


  end

end