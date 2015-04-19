/*jslint browser:true*/
(function () {
  var filtersContainerSelector = '[data-sortable="category-filters"]',
    filtersCancelSelector = '[data-sortable="filter-values"], form',
    filterValuesContainerSelector = '[data-sortable="filter-values"]',
    filterSelector = '[data-filter]',
    filterValueSelector = '[data-filter-value]';

  function reOrder(items, itemType) {
    var attrs = [];
    $(items).each(function (index, item) {
      var str = '', id = $(item).data('id');
      $(item).attr('data-position', index);
      str = 'reorder_' + itemType + '[' + id + '][position]=' + index;
      attrs.push(str);

    });
    return attrs.join('&');
  }

  function sync(params) {
    var postUrl = $(filtersContainerSelector).data('url') + '?' + params;
    $.ajax({
      url: postUrl,
      method: 'POST'
    });
  }

  function onUpdateFilters() {
    var filters = $(filtersContainerSelector + ' ' + filterSelector),
      params = reOrder(filters, 'filters');
    sync(params);
  }

  function onUpdateFilterValues() {
    var filter_values = $(filterValuesContainerSelector + ' ' + filterValueSelector),
      params = reOrder(filter_values, 'filter_values');
    sync(params);
  }

  function CategoryFiltersManager() {
    this.init = function () {
      $(filtersContainerSelector).sortable({
        update: onUpdateFilters,
        cancel: filtersCancelSelector
      });

      $(filterValuesContainerSelector).sortable({
        update: onUpdateFilterValues
      });
    };
  }

  window.Kiosk = window.Kiosk || {};
  window.Kiosk.CategoryFiltersManager = new CategoryFiltersManager();

  $(document).ready(function () {
    window.Kiosk.CategoryFiltersManager.init();
    console.log('Initialized Category Filters Manager...');
  });

}());
