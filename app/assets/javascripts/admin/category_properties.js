/*jslint browser:true*/
(function () {
  var containerSelector = '[data-sortable="category-properties"]';
/*                              CONSTRUCTOR                                   */
  function CategoryPropertyManager() {
    var itemSelector  = '[data-position]',
      delSelector   = '[data-destroy-property]',
      that = this;

    this.categoryId  = $(containerSelector).data('categoryId');
    this.categoryURL = ['/admin/categories', this.categoryId].join('/');
    this.reOderURL   = [this.categoryURL, 'properties/reorder'].join('/');
    this.delURL      = [this.categoryURL, 'properties/remove_property'].join('/');
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
    this.init = function () {
      $(containerSelector).sortable({
        update: onUpdate
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
        node = this;
      $.ajax({
        url: that.delURL,
        method: 'DELETE',
        data: { property_id: id },
        success: function () { $(node).closest(itemSelector).fadeOut(); }
      });
      event.preventDefault();
    };
  }
/*                              EXPORTS                                       */
  window.Kiosk = window.Kiosk || {};
  window.Kiosk.CategoryPropertyManager = new CategoryPropertyManager();
  $(document).ready(function () {
    if ($(containerSelector).size()) {
      console.log('Initialized Category Properties Manager...');
      window.Kiosk.CategoryPropertyManager.init();
    }
  });
/*                              /EXPORTS                                      */
}());
