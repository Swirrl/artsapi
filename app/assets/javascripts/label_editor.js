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
        promise.resolve(response["text"], el);
      },
      error: function(message){
        promise.reject(message["text"]);
      }
    });

    return promise;
  }

  function refreshLabel(label, el){
    $(el).parent().html(label);
    $('span.resource-label').html(label);
  }

  function logError(msg) {
    console.log(msg);
  }

  /* 
    so the thinking behind this is you add an anchor tag
    of class .edit-label with a uri data attribute to a UI element
    that shows a resource label. The parent's HTML will be updated
    as well as the contents of any span tags with the class .resource-label
  */
  $(function(){
    $('a.edit-label').on('click', function(e){
      e.preventDefault();
      e.stopPropagation();
      var uri = $(this).data('uri');
      var label = window.prompt("Enter the new label for this resource:").replace(/\+/," ");
      editLabelByAjax(uri, label, this).then(refreshLabel, logError);
    });
  });
})($, window);