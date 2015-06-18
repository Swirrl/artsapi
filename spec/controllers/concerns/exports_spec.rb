require 'rails_helper'

describe Exports do

  it_behaves_like "given a db with two organisations" do

    # mock a signed-in user for DB queries
    before { User.current_user = user }

    describe "#assemble_person_list_csv" do
      it { expect(Exports.assemble_person_list_csv).not_to be_blank }

      it "should have the right structure and number of rows" do 
        expect(!!(Exports.assemble_person_list_csv.match(/Person\,Sector\,City\,Country\nJeff Lebowsk[a-z]+\,(?:[A-z]|")*\,(?:[A-z]|")*\,(?:[A-z]|")*\nJeff Lebowsk[a-z]+\,(?:[A-z]|")*\,(?:[A-z]|")*\,(?:[A-z]|")*\nJeff Lebowsk[a-z]+\,(?:[A-z]|")*\,(?:[A-z]|")*\,(?:[A-z]|")*\n/)[0])).to eq true
      end
    end

    describe "#assemble_person_matrix_csv" do
      it { expect(Exports.assemble_person_matrix_csv).not_to be_blank }

      it "should have the right structure, number of rows and results" do
        expect(!!(Exports.assemble_person_matrix_csv.match(/Person\,jeff@widgetcorp.org\,walter@widgetcorp.org\,john@nyc.gov\njeff@widgetcorp.org\,""\,3\,2\nwalter@widgetcorp.org\,3\,""\,""\njohn@nyc.gov\,2\,""\,""\n/)[0])).to eq true
      end
    end

    describe "#dump_people_as_csv" do
      it { expect(Exports.dump_people_as_csv).not_to be_blank }

      it "should have the right structure, number of rows and data we expect" do
        expect(!!(Exports.dump_people_as_csv.match(/URI\,Label\,Human Readable Name\,Name\,Email\,Number of Connections\,Position\,Subject Area\,Number of Sent Emails\,Number of Received Emails\,Organisation Name\,Organisation URI\,Sector\,City\,Country\nhttp:\/\/data.artsapi.com\/id\/people\/jeff-widgetcorp-org\,""\,Jeff [A-z]+\,Jeff [A-z]+\,jeff@widgetcorp.org\,2\,""\,\,3\,3\,widgetcorp.org\,http:\/\/data.artsapi.com\/id\/organisations\/widgetcorp-org\,""\,""\,""\nhttp:\/\/data.artsapi.com\/id\/people\/walter-widgetcorp-org\,""\,Jeff [A-z]+\,Jeff [A-z]+\,walter@widgetcorp.org\,""\,""\,\,1\,2\,widgetcorp.org\,http:\/\/data.artsapi.com\/id\/organisations\/widgetcorp-org\,""\,""\,""\nhttp:\/\/data.artsapi.com\/id\/people\/john-nyc-gov\,""\,Jeff [A-z]+\,Jeff [A-z]+\,john@nyc.gov\,""\,""\,\,1\,1\,widgetcorp.org\,http:\/\/data.artsapi.com\/id\/organisations\/nyc-gov\,""\,""\,""/)[0])).to eq true
      end
    end

  end
end