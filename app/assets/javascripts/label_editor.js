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
    $(el).parent().html(label);
  }

  function logError(msg) {
    console.log(msg);
  }

  /* 
    so the thinking behind this is you add an anchor tag
    of class .edit-label with a uri data attribute to a UI element
    that shows a resource label. The parent's HTML
  */
  $(function(){
    $('a.edit-label').on('click', function(e){
      e.preventDefault();
      var uri = $(this).data('uri');
      var label = prompt("Enter the new label for this resource:");
      editLabelByAjax(uri, label, this).then(refreshLabel, logError);
    });
  });
})($, window);