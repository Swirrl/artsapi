(function($, window){
  function editLabelByAjax(uri, label, el){
    var promise = $.Deferred();
    var url = '/edit_label';

    $.ajax({
      url: url,
      data: {
        uri: uri,
        label: label
      },
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
    $(el).html(label);
  }

  function logError(msg) {
    console.log(msg);
  }

  $(function(){
    $('a.edit-label').on('click', function(e){
      e.preventDefault();
      var uri = $(this).data('uri');
      var label = prompt("Enter the new label for this resource:");
      editLabelByAjax(uri, label, this).then(refreshLabel, logError);
    });
  });
})($, window);