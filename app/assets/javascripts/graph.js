(function($, window){

  var GraphVis = function(jsonRequestPath, gravityValue, linkDistance){

    var self = this;

    this.init = function(){
      var width = $(window).width() - 15,
        height = 1000;

      var color = d3.scale.category20();

      var distance = (typeof linkDistance !== 'undefined') ? linkDistance : 120;

      var force = d3.layout.force()
          .gravity(gravityValue)
          .charge(-600)
          .linkDistance(distance)
          .size([width, height]);

      var svg = d3.select("#graph-vis").append("svg")
          .attr("width", width)
          .attr("height", height);

      d3.json(jsonRequestPath, function(error, graph) {
        $('#graph-loading-placeholder').fadeOut('fast');

        if(graph.nodes.length < 100){
          force.size([width, 600]);
        }

        // cribbed example to do collision
        var padding = 1,
            radius = 8;

        function collide(alpha) {
          var quadtree = d3.geom.quadtree(graph.nodes);
          return function(d) {
            var rb = 2 * radius + padding,
                nx1 = d.x - rb,
                nx2 = d.x + rb,
                ny1 = d.y - rb,
                ny2 = d.y + rb;
            quadtree.visit(function(quad, x1, y1, x2, y2) {
              if (quad.point && (quad.point !== d)) {
                var x = d.x - quad.point.x,
                    y = d.y - quad.point.y,
                    l = Math.sqrt(x * x + y * y);
                  if (l < rb) {
                  l = (l - rb) / l * alpha;
                  d.x -= x *= l;
                  d.y -= y *= l;
                  quad.point.x += x;
                  quad.point.y += y;
                }
              }
              return x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1;
            });
          };
        }

        // cribbed example to do node and link highlighting
        var toggle = 0;
        var linkedByIndex = {};

        for (i = 0; i < graph.nodes.length; i++) {
          linkedByIndex[i + "," + i] = 1;
        };

        graph.links.forEach(function (d) {
          linkedByIndex[d.source.index + "," + d.target.index] = 1;
        });

        function neighboring(a, b) {
          return linkedByIndex[a.index + "," + b.index];
        }

        function connectedNodes() {
          if (toggle == 0) {

            var d = d3.select(this).node().__data__;

            node.style("opacity", function(o) {
              if(neighboring(d, o) || neighboring(o, d)){
                return 1;
              } else {
                return 0.1;
              }
            });

            text.style("opacity", function(o) {
              if(neighboring(d, o) || neighboring(o, d)){
                return 1;
              } else {
                return 0.1;
              }
            });

            link.style("opacity", function(o) {
              return (d.index === o.source.index || d.index === o.target.index) ? 1 : 0.1;
            });

            toggle = 1;
          } else {
            node.style("opacity", 1);
            link.style("opacity", 1);
            text.style("opacity", 1);
            toggle = 0;
          }
        }

        function dereferenceURI(){
          var d = d3.select(this).node().__data__;
          var uri = d.uri;
          uri = uri.replace("http://data.artsapi.com", '');
          window.location.href = uri;
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

        var gnodes = svg.selectAll('g.gnode')
            .data(graph.nodes)
          .enter()
            .append('g')
            .classed('gnode', true);

        var node = gnodes.append("circle")
            .attr("class", "node")
            .attr("r", function(d) { return (d.org === undefined) ? 5 : 8; })//5)
            .style("fill", function(d) { return color(d.group); })
            .call(force.drag)
            .on('click', connectedNodes)
            .on('dblclick', dereferenceURI);

        var text = gnodes.append("text")
            .text(function(d) { return d.name; });

        node.append("title")
          .text(function(d) { 
            return d.name 
              + "\n" 
              + d.uri 
              + "\n" 
              + "Weight: " 
              + d.weight 
              + ((d.connections === undefined) ? '' : "\n" + "Connections: " + d.connections) 
              + "\n" 
              + "SIC Sector: " 
              + ((d.sector === undefined || d.sector === null) ? 'Unavailable' : d.sector) 
              + "\n" 
              + (d.orgLocation === undefined ? 'Location Unavailable' : d.orgLocation);
          });

        force.on("tick", function() {
          link.attr("x1", function(d) { return d.source.x; })
              .attr("y1", function(d) { return d.source.y; })
              .attr("x2", function(d) { return d.target.x; })
              .attr("y2", function(d) { return d.target.y; });

          node.attr("cx", function(d) { return d.x; })
              .attr("cy", function(d) { return d.y; });

          text.attr("x", function(d) { return (d.x + 10); })
              .attr("y", function(d) { return d.y; })
          node.each(collide(0.5));
        });
      }).header("Content-Type", "application/json");
    };

  };

  // go go gadget namespaces
  window.artsapi = window.artsapi || new Object();
  window.artsapi.GraphVis = GraphVis;

})($, window)