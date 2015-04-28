require 'rails_helper'

describe 'Email' do
  it_behaves_like "given a db with two organisations" do

    # mock a signed-in user for DB queries
    before { User.current_user = user }

    context "class methods" do

      describe "#total_count" do

        it { expect(Email.total_count).to eq Email.all.resources.count }

      end

    end

  end
end