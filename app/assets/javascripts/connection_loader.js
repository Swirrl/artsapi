(function($, window){

  // call reinforcements
  window.artsapi = window.artsapi || new Object();

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

  function logError(msg) {
    console.log(msg);
  }

  $(function(){

    $('a#recalculate-connections').on('click', function(e){
      e.stopPropagation();
      e.preventDefault();
      var uri = $(this).data('uri');
      calculateConnectionsByAjax(uri).then(logSuccess, logError);
    });

  });
})($, window);