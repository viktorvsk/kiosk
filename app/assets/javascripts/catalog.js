//= require nouislider
//= require_tree ./catalog
//= require animated-header/rAF
//= require animated-header/demo-1
//= require animated-header/TweenLite.min
//= require animated-header/EasePack.min

$(document).ready(function () {
  $('.search-example').click(function (event) {
    $(this).closest('form').find('input[type="search"]').val($(this).text());
    $(this).closest('form').submit();
    event.preventDefault();
  });

  $(document).on('click', '[data-product-view]', function (event) {
    Kiosk.Common.switchView($(this).data('product-view'));
    event.preventDefault();
  });
});
