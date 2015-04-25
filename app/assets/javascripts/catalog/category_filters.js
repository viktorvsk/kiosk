/*jslint browser:true*/
(function () {

  var anySelector, filterSelector, brandSelector;
  anySelector = '[data-price-min], [data-price-max], [data-filter], [data-brand]';
  filterSelector = '[data-filter]';
  brandSelector = '[data-brand]';
  function CatalogCategoryFiltersManager() {

    function onFilter() {
      var filterIDs = [],
        brandIDs = [],
        args = [],
        priceMin = $('[data-price-min]').val(),
        priceMax = $('[data-price-max]').val();

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

      console.log(args.join('&'));


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
