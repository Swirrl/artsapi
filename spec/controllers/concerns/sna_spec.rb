require 'rails_helper'

describe SNA do

  it_behaves_like "given a db with two organisations" do

    # mock a signed-in user for DB queries
    before { User.current_user = user }

    describe "#potential_connections" do
      it { expect(SNA.potential_connections).not_to be 0 }
      it { expect(SNA.potential_connections).to be > 0 }
      it { expect(SNA.potential_connections).to be 3 }
      it { expect(SNA.potential_connections).not_to be_nil }
    end

    describe "#network_density" do
      it { expect(SNA.network_density).not_to be 0 }
      it { expect(SNA.network_density).to be > 0 }
      it { expect(SNA.network_density).not_to be_nil }
    end

    describe "#indegree_outdegree_for_person" do
      it { expect(SNA.indegree_outdegree_for_person(jeff.uri)).not_to be_empty }
    end

    describe "#degree_centrality_for_person" do
      it { expect(SNA.degree_centrality_for_person(jeff.uri)).not_to be 0 }
      it { expect(SNA.degree_centrality_for_person(jeff.uri)).to be > 0 }
      it { expect(SNA.degree_centrality_for_person(jeff.uri)).not_to be_nil }
    end

  end
end