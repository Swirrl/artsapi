function getLabelByAjax(uri, el){
  var promise = $.Deferred();
  var url = '/label';

  $.ajax({
    url: url,
    data: {uri: uri},
    type: 'post',
    dataType: 'json',
    beforeSend: function(xhr){
      xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
    },
    success: function(response){
      promise.resolve(response, el);
    },
    error: function(message){
      promise.reject(message);
    }
  });promise

  return promise;
}

function refreshLabel(label, el){
  $(el).text = label;
}

$(function(){
  $('a.ajax-label').each(function(){
    var uri = $(this).data('uri');
    console.log('Loading label for ' + uri);
    getLabelByAjax(uri, this).then(refreshLabel);
  });
});
