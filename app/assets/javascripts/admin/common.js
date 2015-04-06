/*jslint browser:true */
(function () {
  function Common() {
    this.startLoading = function () {
      $('body').addClass('loading');
    };

    this.finishLoading = function () {
      $('body').removeClass('loading');
    };

    this.toggler = function (event) {
      var attr = $(this).data('toggler'),
        selector = '[data-toggleable="' + attr + '"]',
        $node = $(selector),
        visible = $node.css('display') === 'block';
      if (visible) {
        $(this).text('Показать фильтры');
      } else {
        $(this).text('Скрыть фильтры');
      }
      $node.fadeToggle(100);
      event.preventDefault();
    };
  }

  window.Kiosk = window.Kiosk || {};
  window.Kiosk.Common = new Common();
}());
