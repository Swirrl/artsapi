require 'rails_helper'

module Presenters
  describe Resource do

    it_behaves_like "given a db with two organisations" do

      context "a resource type" do

        it "should have a presenter" do
          expect(jeff.presenter.nil?).to be false
        end

        it "should have a presenter of the default class" do
          expect(jeff.presenter.class.to_s).to eq "Presenters::Resource"
        end

        it "should be possible to override the default class" do
          class ::Foo; def initialize(obj); end; end
          jeff.presenter_type = Foo
          expect(jeff.presenter.class.to_s).to eq "Foo"
        end

      end

      context "an initialized person" do

        before do
          @jeff = jeff
          @jeff.presenter_type = Presenters::PersonPresenter
        end

        it "should be possible to set a Person Presenter" do
          expect(@jeff.presenter.class.to_s).to eq "Presenters::PersonPresenter"
        end

        it "should populate #fields" do
          expect(@jeff.presenter.fields).not_to be_empty
        end

        it "should be able to join arrays on multivalued fields" do
          fields = @jeff.presenter.fields
          expect(fields[2][0]).to eq "Name"
          expect(!!(fields[2][2].match(/Jeff Lebowsk[a-z]+/)[0])).to eq true
        end

        it "fields should have number of emails" do
          email_field = @jeff.presenter.fields.map { |f| f if f[0] == "Made" }.compact.flatten
          expect(email_field[2]).to eq "3 Emails"
        end

        it "#create_link_from_uri should be able to create a uri" do
          link = Presenters::Resource.create_link_from_uri(URI("http://artsapi.com/id/people/jeff-widgetcorp-org"))
          expect(link).to eq "<a href='/id/people/jeff-widgetcorp-org'>http://artsapi.com/id/people/jeff-widgetcorp-org</a>"
        end

      end

    end

  end
end