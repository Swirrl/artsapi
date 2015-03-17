(function($, window){

  var GraphVis = function(uri){

      var self = this;
      var path = '/get_connections_for_graph?uri=' + uri;

      this.init = function(){
        var width = 960,
          height = 500;

        var color = d3.scale.category20();

        var force = d3.layout.force()
            .charge(-120)
            .linkDistance(30)
            .size([width, height]);

        var svg = d3.select("#graph-vis").append("svg")
            .attr("width", width)
            .attr("height", height);

        d3.json(path, function(error, graph) {
          force
              .nodes(graph.nodes)
              .links(graph.links)
              .start();

          var link = svg.selectAll(".link")
              .data(graph.links)
            .enter().append("line")
              .attr("class", "link")
              .style("stroke-width", function(d) { return Math.sqrt(d.value); });

          var node = svg.selectAll(".node")
              .data(graph.nodes)
            .enter().append("circle")
              .attr("class", "node")
              .attr("r", 5)
              .style("fill", function(d) { return color(d.group); })
              .call(force.drag);

          node.append("title")
              .text(function(d) { return d.name; });

          force.on("tick", function() {
            link.attr("x1", function(d) { return d.source.x; })
                .attr("y1", function(d) { return d.source.y; })
                .attr("x2", function(d) { return d.target.x; })
                .attr("y2", function(d) { return d.target.y; });

            node.attr("cx", function(d) { return d.x; })
                .attr("cy", function(d) { return d.y; });
          });
        }).header("Content-Type", "application/json");
      };

  };

  // go go gadget namespaces
  window.artsapi = window.artsapi || new Object();
  window.artsapi.GraphVis = GraphVis;

})($, window)