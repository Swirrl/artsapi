function getConnectionsByAjax(uri){
  var promise = $.Deferred();
  var url = '/connections';

  $.ajax({
    url: url,
    data: {uri: uri},
    type: 'post',
    dataType: 'json',
    beforeSend: function(xhr){
      xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
    },
    success: function(response){
      console.log(response["text"]);
      promise.resolve(response);
    },
    error: function(message){
      promise.reject(message);
    }
  });

  return promise;
}

function reloadPage(response){
  //alert('Loading complete. The page will now refresh.');
  //window.location.reload();
}

function logError(msg) {
  console.log(msg);
}

$(function(){
  $('a#recalculate-connections').on('click', function(e){
    e.stopPropagation();
    e.preventDefault();
    var uri = $(this).data('uri');
    getConnectionsByAjax(uri).then(reloadPage, logError);
  });
});