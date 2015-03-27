(function($, window){

  var ChartVis = function(csvRequestPath){

      var self = this;

      this.init = function(){

        var margin = {top: 20, right: 20, bottom: 30, left: 50},
            width = ($(window).width() - 15) - margin.left - margin.right,
            height = 400 - margin.top - margin.bottom;

        var bisectEmails = d3.bisector(function(d) { return d.emails; }).left;

        var x = d3.scale.linear()
            .range([0, width]);

        var y = d3.scale.linear()
            .range([height, 0]);

        var xAxis = d3.svg.axis()
            .scale(x)
            .orient("bottom")
            .ticks(5);

        var yAxis = d3.svg.axis()
            .scale(y)
            .orient("left")
            .ticks(5);

        var valueline = d3.svg.line()
            .x(function(d) { return x(d.emails); })
            .y(function(d) { return y(d.occurrences); });

        var svg = d3.select("#chart-vis").append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
          .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

        var focus = svg.append("g")
            .style("display", "none");

        // Get the data
        d3.csv(csvRequestPath, function(error, data) {
            data.forEach(function(d) {
              d.occurrences = +d.occurrences;
              d.emails = +d.emails;
            });

            // Scale the range of the data
            x.domain(d3.extent(data, function(d) { return d.emails; }));
            y.domain([0, d3.max(data, function(d) { return d.occurrences; })]);

            // Add the valueline path.
            svg.append("path")
                .attr("class", "line")
                .attr("d", valueline(data));

            // Add the X Axis
            svg.append("g")
                .attr("class", "x axis")
                .attr("transform", "translate(0," + height + ")")
                .call(xAxis);

            // Add the Y Axis
            svg.append("g")
                .attr("class", "y axis")
                .call(yAxis);

            // Add legend to X and Y
            svg.append("text")
                .attr("x", width / 2 )
                .attr("y", height + margin.bottom)
                .style("text-anchor", "middle")
                .text("No. of Emails Exchanged");

            svg.append("text")
                .attr("transform", "rotate(-90)")
                .attr("y", 0 - margin.left)
                .attr("x",0 - (height / 2))
                .attr("dy", "1em")
                .style("text-anchor", "middle")
                .text("No. of Connections");

            // // Append the circle at the intersection
            // focus.append("circle")
            //     .attr("class", "y")
            //     .style("fill", "none")
            //     .style("stroke", "blue")
            //     .attr("r", 4);
            
            // // Append the rectangle to capture mouse
            // svg.append("rect")
            //     .attr("width", width)
            //     .attr("height", height)
            //     .style("fill", "none")
            //     .style("pointer-events", "all")
            //     .on("mouseover", function() { focus.style("display", null); })
            //     .on("mouseout", function() { focus.style("display", "none"); })
            //     .on("mousemove", mousemove);

            // function mousemove() {
            //     var x0 = x.invert(d3.mouse(this)[0]),
            //         i = bisectEmails(data, x0, 1),
            //         d0 = data[i - 1],
            //         d1 = data[i],
            //         d = x0 - d0.emails > d1.emails - x0 ? d1 : d0;

            //     focus.select("circle.y")
            //         .attr("transform", "translate(" + x(d.emails) + "," + y(d.occurrences) + ")");
            // }

        });
      };

  };

  // go go gadget namespaces
  window.artsapi = window.artsapi || new Object();
  window.artsapi.ChartVis = ChartVis;

})($, window)