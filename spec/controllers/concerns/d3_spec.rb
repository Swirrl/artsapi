require 'rails_helper'

describe D3 do

  it_behaves_like "given a db with two organisations" do

    # mock a signed-in user for DB queries
    before { User.current_user = user }

    before { jeff.get_connections! }

    describe "generating a graph for a person" do

      before { @connections = D3::ConnectionsGraph.new(jeff).conn_hash }

      it "should not be empty" do
        expect(@connections).not_to be_empty
      end

      it "should appear structurally correct" do
        nodes = @connections["nodes"]
        links = @connections["links"]
        expect(nodes).not_to be_empty
        expect(links).not_to be_empty
      end

      it "should contain no nils" do
        nodes = @connections["nodes"]
        links = @connections["links"]

        compacted_nodes = nodes.map {|n| n if (!n[:id].nil? && !n[:name].nil? && !n[:uri].nil? && !n[:group].nil?) }
        compacted_links = links.map {|n| n if (!n[:source].nil? && !n[:target].nil? && !n[:value].nil?) }

        expect(compacted_nodes.length).to eq nodes.length
        expect(compacted_links.length).to eq links.length
      end

    end

    describe "generating a graph for an organisation" do

      before { @formatted_hash = D3::OrganisationsGraph.new(organisation).formatted_hash }

      it "should not be empty" do
        expect(@formatted_hash).not_to be_empty
      end

      it "should appear structurally correct" do
        nodes = @formatted_hash["nodes"]
        links = @formatted_hash["links"]
        expect(nodes).not_to be_empty
        expect(links).not_to be_empty
      end

      it "should contain no nils" do
        nodes = @formatted_hash["nodes"]
        links = @formatted_hash["links"]

        compacted_nodes = nodes.map {|n| n if (!n[:id].nil? && !n[:name].nil? && !n[:uri].nil? && !n[:group].nil?) }
        compacted_links = links.map {|n| n if (!n[:source].nil? && !n[:target].nil? && !n[:value].nil?) }

        expect(compacted_nodes.length).to eq nodes.length
        expect(compacted_links.length).to eq links.length
      end

    end

    describe "generating a line chart for a person" do

      before { @connections = D3::ConnectionsChart.new(jeff).csv }

      it "should not be empty" do
        expect(@connections).not_to be_empty
      end

      it "should appear structurally correct" do
        expect(!!(@connections.match(/occurrences,emails\n[0-9]+\,[0-9]+\n[0-9]+\,[0-9]+\n/)[0])).to eq true # should look like "occurrences,emails\n1,12\n1,8\n"
      end

      it "should contain no nils" do
        expect(@connections.match(/nil/)).to eq nil
      end

    end

  end

end