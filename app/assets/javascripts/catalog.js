//= require nouislider
//= require_tree ./catalog
//= require animated-header/rAF
//= require animated-header/demo-1
//= require animated-header/TweenLite.min
//= require animated-header/EasePack.min
//= require jQuery-Mask-Plugin

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

  $('[type="tel"]').mask('+38 (000) 000-00-00', { placeholder: '+38(___)___-__-__' })

  $(".cd-top").click(function(event) {
    event.preventDefault();
    $('html, body').animate({
      scrollTop: $("#top_point").offset().top
    }, 400);
  });

  $('.search-example').click(function (event) {
    $('#q_main_search').closest('form').find('input[type="search"]').val($(this).text());
    $('#q_main_search').closest('form').submit();
    event.preventDefault();
  });

  $('#q_main_search').focus(function () {
    $('[data-search-autocomplete]').show('fast');
  });

  $('#q_main_search').blur(function () {
    setTimeout(function () {
      $('[data-search-autocomplete]').hide('fast');
    }, 50);

  });

  $(document).on('click', '[data-product-view]', function (event) {
    Kiosk.Common.switchView($(this).data('product-view'));
    event.preventDefault();
  });

  $(document).on('keyup', '#q_main_search', function () {
    typeWatcher(mainSearchPerform, 500);

  });

  $('[data-compare]').click(function (event) {
    var action;
    $('[data-compare]').removeClass('btn btn-primary');
    $(this).addClass('btn btn-primary');
    if ($(this).data('compare') === 'all') {
      $('[data-compare="tr"]').show('slow');
    } else {
      $('[data-compare="tr"]').each(function (index, item) {
        var values = [];
        $(item).find('.product_compare_property').each(function (p_index, p_item) {
          var txt = $.trim($(p_item).text());
          if ($.inArray(txt, values) === -1) {
            values.push(txt);
          }
        });
        if (values.length === 1) {
          $(item).hide('slow');
        }
      });
    }

    event.preventDefault();
  });
});
