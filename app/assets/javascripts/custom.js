// custom js
// all account js function defined here

$.urlParam = function(url, name){
  name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
  var regex = new RegExp('[\\?&]' + name + '=([^&#]*)');
  var results = regex.exec(url);
  return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '));
}

$(document).ready(function(){

  //
  // to submit modal form with btn with class submit-modal-form
  //
  $('body').on("click", "button.submit-modal-form", function(e){

    currentModal = $(this).closest('div.modal');
    if (currentModal.length > 0){
      //check whether confirmed class is present
      if ($(this).hasClass('confirmed')) {
        //currentModal.find('form').submit();
        if (currentModal.find('form button.modal-form-submit').length == 0){
          currentModal.find('form').append("<button class='hidden modal-form-submit' type='submit'>Submit</button>");
        }
        $(this).removeClass('confirmed');
        currentModal.find('form button.modal-form-submit').trigger("click");
      }
      // check if data-confirmation is present
      if ($(this).attr('data-confirmation')){
         e.preventDefault();
      }
    }

  });

  //
  // show modal if already exists on click modal links
  //
  $("body").on("click", "a.remote-modal", function(e){
    modal_id = $.urlParam(decodeURIComponent($(this).attr('href')), 'modal[id]');
    if ((modal_id != null) && (modal_id.trim()) )
    {
      if ($("div#"+modal_id+"").length > 0){
        $("div#"+modal_id+"").modal('show');
        e.preventDefault();
        return false;
      }
    }
  });

});





