require 'rails_helper'

describe 'Keyword' do

  context "class methods" do

    describe "#label_from_uri" do

      it "should return the correct label when given a string" do
        expect(Keyword.label_from_uri("http://artsapi.com/id/keywords/keyword/explore")).to eq "Explore"
      end

      it "should return the correct label when given a RDF::URI" do
        expect(Keyword.label_from_uri(RDF::URI("http://artsapi.com/id/keywords/keyword/explore"))).to eq "Explore"
      end

    end

  end

end