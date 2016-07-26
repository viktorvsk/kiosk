/*jslint browser:true*/
(function () {
  var containerSelector = '[data-sortable="category-properties"]';
/*                              CONSTRUCTOR                                   */
  function CategoryPropertyManager() {
    var itemSelector = '[data-position]',
      delSelector = '[data-destroy-property]',
      newSelector = '#catalog_property_name',
      autocompletePath = '/admin/autocomplete/properties',
      that = this;

    this.categoryId  = $(containerSelector).data('categoryId');
    this.categoryURL = ['/admin/categories', this.categoryId].join('/');
    this.reOderURL   = [this.categoryURL, 'properties/reorder_category'].join('/');
    this.delURL      = [this.categoryURL, 'properties'].join('/');
    /*                              PRIVATE                                   */

    function reOrder(items) {
      var attrs = [];
      $(items).each(function (index, item) {
        var str = '', id = $(item).data('id');
        $(item).attr('data-position', index);
        str = 'properties[' + id + '][position]=' + index;
        attrs.push(str);
      });
      return attrs.join('&');
    }

    function onUpdate() {
      var items = $(containerSelector + ' ' + itemSelector),
        params = reOrder(items);
      that.sync(params);
    }


    /*                              PUBLIC                                    */
    this.update = onUpdate;
    this.getContainerSelector = function () {
      return containerSelector;
    };

    this.init = function () {
      $(containerSelector).sortable({
        update: onUpdate
      });

      $(newSelector).autocomplete({
        source: autocompletePath,
        minLength: 2,
        select: function (event, ui) {
          console.log(event, ui);
        }
      });


      $(delSelector).on('click', that.onDelete);
    };

    this.sync = function (params) {
      $.ajax({
        url: that.reOderURL + '?' + params,
        method: 'PATCH'
      });
    };

    this.onDelete = function (event) {
      var id = $(this).data('destroy-property'),
        node = this,
        url = [that.delURL, id, 'destroy_category_property'].join('/');
      $.ajax({
        url: url,
        method: 'DELETE',
        success: function () { $(node).closest(itemSelector).fadeOut(); }
      });
      event.preventDefault();
    };
  }
/*                              EXPORTS                                       */
  window.Kiosk = window.Kiosk || {};
  window.Kiosk.CategoryPropertyManager = new CategoryPropertyManager();
  $(document).ready(function () {
    if ($(containerSelector).length) {
      console.log('Initialized Category Properties Manager...');
      window.Kiosk.CategoryPropertyManager.init();
    }
  });
/*                              /EXPORTS                                      */
}());
