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
  });

  return promise;
}

function refreshLabel(label, el){
  labelText = label["text"].replace(/(\r\n|\n|\r)/gm,"");
  $(el).html(labelText);
}

function logError(msg) {
  console.log(msg);
}

$(function(){
  $('a.ajax-label').each(function(){
    var uri = $(this).data('uri');
    getLabelByAjax(uri, this).then(refreshLabel, logError);
  });
});
