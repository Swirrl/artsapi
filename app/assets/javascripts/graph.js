(function($, window){

  var GraphVis = function(jsonRequestPath, gravityValue){

    var self = this;

    this.init = function(){
      var width = $(window).width() - 15,
        height = 1000;

      var color = d3.scale.category20();

      var force = d3.layout.force()
          .gravity(gravityValue)
          .charge(-600)
          .linkDistance(120)
          .size([width, height]);

      var svg = d3.select("#graph-vis").append("svg")
          .attr("width", width)
          .attr("height", height);

      d3.json(jsonRequestPath, function(error, graph) {
        $('#graph-loading-placeholder').fadeOut('fast');

        if(graph.nodes.length < 100){
          force.size([width, 600]);
        }

        force
            .nodes(graph.nodes)
            .links(graph.links)
            .start();

        var link = svg.selectAll(".link")
            .data(graph.links)
          .enter().append("line")
            .attr("class", "link")
            .style("stroke-width", function(d) { return Math.sqrt(d.value / 4); });

        var node = svg.selectAll(".node")
            .data(graph.nodes)
          .enter().append("circle")
            .attr("class", "node")
            .attr("r", function(d) { return (d.org === undefined) ? 5 : 8; })//5)
            .style("fill", function(d) { return color(d.group); })
            .call(force.drag);

        node.append("title")
            .text(function(d) { return d.name + "\n" + d.uri; });

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