/*jslint browser:true*/
(function () {
  var containerSelector = '[data-sortable="product-properties"]',
    formInputSelector = containerSelector + ' form input';
/*                              CONSTRUCTOR                                   */
  function ProductPropertyManager() {
    var itemSelector = '[data-position]',
      delSelector = '[data-destroy-property]',
      newSelector = '#catalog_property_name',
      autocompletePath = '/admin/autocomplete/properties',
      that = this;

    this.productId  = $(containerSelector).data('productId');
    this.productURL = ['/admin/products', this.productId].join('/');
    this.reOderURL   = [this.productURL, 'properties/reorder_product'].join('/');
    this.delURL      = [this.productURL, 'product_properties'].join('/');
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

      $(formInputSelector).on('change', function () {
        $(this).closest('form').submit();
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
        url = [that.delURL, id].join('/');
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
  window.Kiosk.ProductPropertyManager = new ProductPropertyManager();
  $(document).ready(function () {
    if ($(containerSelector).size()) {
      console.log('Initialized Product Properties Manager...');
      window.Kiosk.ProductPropertyManager.init();
    }
  });
/*                              /EXPORTS                                      */
}());
