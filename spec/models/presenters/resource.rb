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

    end

  end
end