/*jslint browser: true */

(function () {
  function BindingManager() {
    var that = this;

    this.vendorProduct        = '[data-draggable="vendorProduct"]';
    this.product              = '[data-droppable="product"]';
    this.vendorProductsTable  = '[data-droppable="vendorProductsTable"]';
    this.productsTable        = '[data-catalog-products]';
    this.dataVendorProductId  = 'vendor-product-id';
    this.dataProductId        =  'product-id';
    this.bindClass            = 'bind-to-product';
    this.unbindClass          = 'unbind-vendor-product';
    this.spinnerClass         = 'glyphicon glyphicon-refresh fa-spin';
    this.activationClass      = '[data-activation-toggle]';
    this.updateVendorModel    = 'form.edit_vendor_product input';
    this.scrapeModal          = '#vendor-product-scraper-window';
    this.searchMarketPath     = '/admin/products/search_marketplaces';
    this.toScrapeSelector     = '[data-product-scraper]';
    this.scrapeURL            = '/admin/products/create_from_marketplace';
    this.modelSelector        = that.scrapeModal + ' h4'

    this.urlForBind = function (product, vendorProduct) {
      var url = ['/admin', 'binding', product, vendorProduct].join('/');
      return url;
    };

    this.urlForUnbind = function (vendorProduct) {
      var url = ['/admin', 'binding', vendorProduct].join('/');
      return url;
    };

    this.urlForRecountProduct = function (id) {
      var url = ['/admin', 'products', id, 'recount'].join('/');
      return url;
    };

    this.urlForUpdateProduct = function (id) {
      var url = ['/admin', 'products', id].join('/');
      return url;
    };

    this.updateProduct = function (product) {
      var spinner = $('<i/>').addClass(that.spinnerClass),
        id = product.data(that.dataProductId),
        url = that.urlForUpdateProduct(id);
      product
        .prepend(spinner)
        .droppable('disable');
      $.get(url, function (data) {


        product.replaceWith(data);
        that.init();
      });

    };

    this.bindFromProduct = function (vendorProduct) {
      var id = vendorProduct.parent().data('product-id');
      return typeof id == 'undefined' ? false : true;
    };

    this.init = function () {
      $(that.vendorProduct).draggable(that.draggableConfig);
      $(that.product).droppable(that.droppableProductConfig);
      $(that.vendorProductsTable).droppable(that.droppableVendorProductConfig);

      $(document).on('click', that.toScrapeSelector, function (event) {
        var url = $(this).data('url'),
          category = $(this).closest('li').find('select').val(),
          model = $(that.modelSelector).text();
          console.log(model);
        $.ajax({
          url: that.scrapeURL,
          method: 'POST',
          data: {
            category_id: category,
            url: encodeURIComponent(url),
            model: encodeURIComponent(model)
          },
          success: function () { $(that.scrapeModal).modal('hide'); }
        });
      });
      $(document).ready(function () {
        $(that.updateVendorModel).on('change', function () {
          $(this).closest('form').submit();
        });

        $(that.scrapeModal).on('hide.bs.modal', function () {
          $(this).off('hide.bs.modal');
        });

        $(that.scrapeModal).on('show.bs.modal', function (event) {
          var model = $(event.relatedTarget).closest('form').find('[data-model]').val();
          $(this).find('h4').text(model);
          $(this).find('.modal-body').text('...');
          $.ajax({
            url: that.searchMarketPath,
            method: 'GET',
            type: 'script',
            data: { model: encodeURIComponent(model) }
          });
        });

      });
    };

    this.bind = function (product, vendorProduct) {
      var url = that.urlForBind(product.data(that.dataProductId), vendorProduct.data(that.dataVendorProductId)),
        oldProduct = that.productFor(vendorProduct);

      $.post(url, function (data) {
        if (that.bindFromProduct(vendorProduct)) {

          that.recountProduct(oldProduct);
        }

        that.updateProduct(product);
      });

    };

    this.productFor = function (vendorProduct) {
      var id = vendorProduct.parent().data('product-id'),
        product = $('li[data-product-id="' + id + '"]');
      return product;
    };

    this.unbind = function (product, vendorProduct) {

      var url = that.urlForUnbind(vendorProduct);
      $.ajax({
        url: url,
        type: 'DELETE',
        success: function (data) {

          that.updateProduct(product);
        }
      });
    };

    this.recountProduct = function (product) {
      if (!product || !product.size()) {
        return;
      }
      var id = product.data(that.dataProductId),
        url = that.urlForRecountProduct(id);
      $.post(url, function () {

        that.updateProduct(product);
      });
    };

    this.onUnbind = function (event, ui) {

      var $vendorProductNode = $(ui.draggable),
        vendorProductId = $vendorProductNode.data(that.dataVendorProductId),
        $product = that.productFor($vendorProductNode);
      that.unbind($product, vendorProductId);
      $vendorProductNode
        .css({ top: 0, left: 0, right: 0, bottom: 0, width: 'auto' })
        .prependTo($(that.vendorProductsTable));
      that.init();
    };

    this.onBind = function (event, ui) {
      var $productNode      = $(this),
        $vendorProductNode  = $(ui.draggable);

      that.bind($productNode, $vendorProductNode);
      $vendorProductNode.appendTo($productNode.find('ul'));
      //$vendorProductNode.remove();
      that.init();
    };

    this.draggableConfig = {
      revert: 'invalid',
      cancel: 'span'
    };

    this.droppableProductConfig = {
      hoverClass: that.bindClass,
      cursorAt: { top: -5, left: -5 },
      drop: that.onBind
    };

    this.droppableVendorProductConfig = {
      hoverClass: that.unbindClass,
      drop: that.onUnbind,
      accept: that.productsTable + ' ' + 'li'
    };

  }

  window.Kiosk = window.Kiosk || {};
  window.Kiosk.BindingManager = new BindingManager();



}());

