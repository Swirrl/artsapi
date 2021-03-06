(function($, window){

  // call reinforcements
  // window.artsapi = window.artsapi || new Object();

  function calculateConnectionsByAjax(uri){
    var promise = $.Deferred();
    var url = '/generate_connections';

    $.ajax({
      url: url,
      data: {uri: uri},
      type: 'post',
      dataType: 'json',
      beforeSend: function(xhr){
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      },
      success: function(response){
        promise.resolve(response["text"]);
      },
      error: function(message){
        promise.reject(message["text"]);
      }
    });

    return promise;
  }

  function getConnectionsByAjax(uri){
    var promise = $.Deferred();
    var url = '/get_connections';

    $.ajax({
      url: url,
      data: {uri: uri},
      type: 'post',
      dataType: 'json',
      beforeSend: function(xhr){
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      },
      success: function(response){
        promise.resolve(response["connections"]);
      },
      error: function(message){
        promise.reject(message["text"]);
      }
    });

    return promise;
  }

  function reloadPage(response){
    alert('Loading complete. The page will now refresh.');
    window.location.reload();
  }

  function logSuccess(msg){
    console.log(msg);
  }

  function alertSuccess(msg){
    alert('Success: ' + msg);
  }

  function logError(msg) {
    console.log(msg);
  }

  function loadConnectionsChart(){
    var resourceUri = $('p#graph-for').data('uriForGraph') || null;

    if(resourceUri !== null){
      var path = '/get_connections_for_chart?uri=' + resourceUri;
      var visualisation = new window.artsapi.ChartVis(path);
      visualisation.init();
    }
  }

  function loadConnectionsGraph(){
    var resourceUri = $('p#graph-for').data('uriForGraph') || null;

    if(resourceUri !== null){
      var path = '/get_connections_for_graph?uri=' + resourceUri;
      var gravity = 0.1;
      var visualisation = new window.artsapi.GraphVis(path, gravity);
      visualisation.init();
    }
  }

  function loadOrganisationGraph(){
    var resourceUri = $('p#organisation-graph-for').data('uriForGraph') || null;

    if(resourceUri !== null){
      var path = '/get_organisation_graph?uri=' + resourceUri;
      var gravity = 0.3;
      var visualisation = new window.artsapi.GraphVis(path, gravity, 200);
      visualisation.init();
    }
  }

  $(function(){

    $('a#recalculate-connections').on('click.calculateConnections', function(e){
      e.stopPropagation();
      e.preventDefault();
      var uri = $(this).data('uri');
      calculateConnectionsByAjax(uri).then(alertSuccess, logError);
    });

    $('a.trigger-chart-load').one('click.chartLoad', function(e){
      // default etc should already be caught by table tabs js
      $('a.trigger-chart-load').off('click.chartLoad');
      $('a.trigger-chart-load').removeClass('trigger-chart-load');
      loadConnectionsChart();
    });

    // wait five seconds to kick off the AJAX extravaganza
    window.setTimeout(loadConnectionsGraph, 5000);
    window.setTimeout(loadOrganisationGraph, 5000);

  });
})($, window);