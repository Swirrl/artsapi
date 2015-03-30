(function($, window){
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
        promise.reject(message["text"]);
      }
    });

    return promise;
  }

  function refreshLabel(label, el){
    labelText = label["text"].replace(/(\r\n|\n|\r)/gm,"");
    $(el).html(labelText);
    $(el).removeAttr('class');
  }

  function logError(msg) {
    console.log(msg);
  }

  function triggerLabelLoad(){
    $('a.ajax-label').each(function(){
      var uri = $(this).data('uri');
      getLabelByAjax(uri, this).then(refreshLabel, logError);
    });
  }

  $(function(){
    $('a.trigger-label-load').on('click', function(e){
      triggerLabelLoad();
    });
  });
})($, window);
