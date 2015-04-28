/*jslint browser:true*/
(function () {

  var anySelector, filterSelector, brandSelector;
  anySelector = '[data-price], [data-price-min], [data-price-max], [data-filter], [data-brand], [data-name], [data-sort]';
  filterSelector = '[data-filter]';
  brandSelector = '[data-brand]';

  function CatalogCategoryFiltersManager() {

    function serialize($initiator) {
      var filterIDs = [],
        brandIDs = [],
        args = [],
        priceMin = 0,
        priceMax = 0,
        name = $('[data-name]').val(),
        sort = $('[data-sort]').val();

      if($initiator.attr('id') !== 'price_max_' && $initiator.attr('id') !== 'price_min_'){
        priceMin = $('[data-price]').val()[0];
        priceMax = $('[data-price]').val()[1];
      } else {
        priceMin = $('[data-price-min]').val();
        priceMax = $('[data-price-max]').val();
      }


      $(filterSelector + ':checked').each(function (index, item) {
        filterIDs.push($(item).data('filter'));
      });

      $(brandSelector + ':checked').each(function (index, item) {
        brandIDs.push($(item).data('brand'));
      });

      args.push(['f', filterIDs].join('='));
      args.push(['b', brandIDs].join('='));
      args.push(['min', priceMin].join('='));
      args.push(['max', priceMax].join('='));
      args.push(['name', name].join('='));
      args.push(['o', sort].join('='));

      return args.join('&');
    }

    function onFilter() {
      var initiator = $(this);
      var url = $('h1').data('url');
      url = [url, serialize(initiator)].join('?');
      $.ajax({
        url: url,
        method: 'GET',
        'dataType': 'script',
        success: function () {
          history.pushState(null, null, url);
        }
      });


    }

    this.init = function () {
      $(document).on('change', anySelector, onFilter);
    };
  }

  window.Kiosk = window.Kiosk || {};
  window.Kiosk.CatalogCategoryFiltersManager = new CatalogCategoryFiltersManager();

  $(document).ready(function () {
    if ($(anySelector).size()) {

      window.Kiosk.CatalogCategoryFiltersManager.init();
    }
  });

}());
