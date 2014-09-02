$(function(){
  $('#role_modal_container').on('click', '#save_role', function(){
    $(this).closest('#role_modal').find('form').submit();
  });
});
