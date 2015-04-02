require 'rails_helper'

describe Dispatcher do

  it_behaves_like "given a db with two organisations" do

    describe "a person presenter" do
      it "should be possible to set" do
        jeff.presenter_type = Presenters::PersonPresenter
        expect(jeff.presenter.class.to_s).to eq "Presenters::PersonPresenter"
      end
    end

    describe "a organisation presenter" do
      it "should be possible to set" do
        organisation.presenter_type = Presenters::OrganisationPresenter
        expect(organisation.presenter.class.to_s).to eq "Presenters::OrganisationPresenter"
      end
    end

  end

end