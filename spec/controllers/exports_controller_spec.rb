require 'rails_helper'

describe ExportsController do
  #render_views

  it_behaves_like "given a db with two organisations" do

    describe "person export" do

      before { sign_in user }

      # it "responds with 200" do
      #   post :person_export_csv
      #   expect(response.status).to eq 200
      # end

      it "enqueues a worker" do
        expect {
          Sidekiq::Testing.fake! do
            post :person_export_csv
          end
        }.to change(ExportsWorker.jobs, :size).by(1)
      end

    end

    describe "person matrix" do

      before { sign_in user }

      # it "responds with 200" do
      #   post :person_matrix_csv
      #   expect(response.status).to eq 200
      # end

      it "enqueues a worker" do
        expect {
          Sidekiq::Testing.fake! do
            post :person_matrix_csv
          end
        }.to change(ExportsWorker.jobs, :size).by(1)
      end

    end

    describe "person dump" do

      before { sign_in user }

      # it "responds with 200" do
      #   post :person_dump_csv
      #   expect(response.status).to eq 200
      # end

      it "enqueues a worker" do
        expect {
          Sidekiq::Testing.fake! do
            post :person_dump_csv
          end
        }.to change(ExportsWorker.jobs, :size).by(1)
      end

    end

  end
end