/*jslint browser:true*/
(function () {

  var checkBoxSelector;
  checkBoxSelector = '.category-filter';

  function CatalogCategoryFiltersManager() {

    function onFilter() {
      var ids = [];
      $(checkBoxSelector + ':checked').each(function (index, item) {
        ids.push($(item).data('id'));
      });
      console.log(ids.join(','));
    }

    this.init = function () {
      $(document).on('change', checkBoxSelector, onFilter);
    };
  }

  window.Kiosk = window.Kiosk || {};
  window.Kiosk.CatalogCategoryFiltersManager = new CatalogCategoryFiltersManager();

  $(document).ready(function () {
    if ($(checkBoxSelector).size()) {

      window.Kiosk.CatalogCategoryFiltersManager.init();
    }
  });

}());
