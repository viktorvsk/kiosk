//= require nouislider
//= require_tree ./catalog
//= require animated-header/rAF
//= require animated-header/demo-1
//= require animated-header/TweenLite.min
//= require animated-header/EasePack.min

var mainSearchPerform = function () {
  var q = $('#q_main_search').val();
  var $form = $('#q_main_search').closest('form');
  var url = $form.attr('action');
  if(q.length > 3) {
    $.ajax({
      url: url,
      dataType: 'script',
      data: { 'q[main_search]': q },
      method: 'GET',
      complete: function (data) {
        $('[data-search-autocomplete]').html(data.responseText);
      }
    })
  }
}

var typewatch = function(){
  var timer = 0;
  return function(callback, ms){
    clearTimeout(timer);
    timer = setTimeout(callback, ms);
  }
};

var typeWatcher = typewatch();

$(document).ready(function () {
  $('.search-example').click(function (event) {
    $('#q_main_search').closest('form').find('input[type="search"]').val($(this).text());
    $('#q_main_search').closest('form').submit();
    event.preventDefault();
  });

  $('#q_main_search').focus(function () {
    $('[data-search-autocomplete]').show('slow');
  });

  $('#q_main_search').blur(function () {
    $('[data-search-autocomplete]').hide('slow');
  });

  $(document).on('click', '[data-product-view]', function (event) {
    Kiosk.Common.switchView($(this).data('product-view'));
    event.preventDefault();
  });

  $(document).on('keyup', '#q_main_search', function () {
    typeWatcher(mainSearchPerform, 500);

  });
});
