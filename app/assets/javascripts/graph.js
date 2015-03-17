(function($, window){

  var GraphVis = (function(){
    function GraphVis(uri, arrayOfUris){
      this.init();
    }

    GraphVis.prototype.getLabels = function(){

    }

    GraphVis.prototype.init = function(){

    }

    return GraphVis;
  })();

  // go go gadget namespaces
  window.artsapi = window.artsapi || new Object();
  window.artsapi.GraphVis = GraphVis;

})($, window)