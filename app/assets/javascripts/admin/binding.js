/*jslint browser: true */

(function () {

  var vendorProduct      = '[data-draggable="vendorProduct"]',
    productDroppable     = '[data-droppable="product"]',
    vendorProductsTable  = '[data-droppable="vendorProductsTable"]',
    productsTable        = '[data-catalog-products]',
    dataVendorProductId  = 'vendor-product-id',
    dataProductId        =  'product-id',
    bindClass            = 'bind-to-product',
    unbindClass          = 'unbind-vendor-product',
    spinnerClass         = 'glyphicon glyphicon-refresh fa-spin',
    // activationClass      = '[data-activation-toggle]',
    updateVendorModel    = 'form.edit_vendor_product input',
    scrapeModal          = '#vendor-product-scraper-window',
    searchMarketPath     = '/admin/products/search_marketplaces',
    toScrapeSelector     = '[data-product-scraper]',
    scrapeURL            = '/admin/products/create_from_marketplace',
    modelSelector        = scrapeModal + ' h4',
    draggableConfig = {
      revert: 'invalid',
      cancel: 'span'
    };

  function BindingManager() {
    var that = this,
      droppableProductConfig = {
        hoverClass: bindClass,
        cursorAt: { top: -5, left: -5 },
        drop: onBind
      },
      droppableVendorProductConfig = {
        hoverClass: unbindClass,
        drop: onUnbind,
        accept: productsTable + ' ' + 'li'
      };

    function createFromMarketPlace(event) {
      var url = $(this).data('url'),
        category = $(this).closest('li').find('select').val(),
        model = $(modelSelector).text();
      $.ajax({
        url: scrapeURL,
        method: 'POST',
        data: {
          category_id: category,
          url: encodeURIComponent(url),
          model: encodeURIComponent(model)
        },
        success: function () { $(scrapeModal).modal('hide'); }
      });
      event.preventDefault();
    }

    function searchMarketPlace(event) {
      var model = $(event.relatedTarget).closest('form').find('[data-model]').val();
      $(this).find('h4').text(model);
      $(this).find('.modal-body').text('...');
      $.ajax({
        url: searchMarketPath,
        method: 'GET',
        type: 'script',
        data: { model: encodeURIComponent(model) }
      });
    }

    function urlForBind(product, vendorProduct) {
      var url = ['/admin', 'binding', product, vendorProduct].join('/');
      return url;
    }

    function urlForUnbind(vendorProduct) {
      var url = ['/admin', 'binding', vendorProduct].join('/');
      return url;
    }

    function urlForRecountProduct(id) {
      var url = ['/admin', 'products', id, 'recount'].join('/');
      return url;
    }

    function urlForUpdateProduct(id) {
      var url = ['/admin', 'products', id].join('/');
      return url;
    }

    function bindFromProduct(vendorProduct) {
      var id = vendorProduct.parent().data('product-id');
      return typeof id == 'undefined' ? false : true;
    }

    function bind(product, vendorProduct) {
      var url = urlForBind(product.data(dataProductId), vendorProduct.data(dataVendorProductId)),
        oldProduct = productFor(vendorProduct);

      $.post(url, function (data) {
        if (bindFromProduct(vendorProduct)) {
          recountProduct(oldProduct);
        }
        that.updateProduct(product);
      });

    }

    function productFor(vendorProduct) {
      var id = vendorProduct.parent().data('product-id'),
        product = $('li[data-product-id="' + id + '"]');
      return product;
    }

    function unbind(product, vendorProduct) {
      var url = urlForUnbind(vendorProduct);
      $.ajax({
        url: url,
        type: 'DELETE',
        success: function (data) {
          that.updateProduct(product);
        }
      });
    }

    function recountProduct(product) {
      if (!product || !product.length) {
        return;
      }
      var id = product.data(dataProductId),
        url = urlForRecountProduct(id);
      $.post(url, function () {

        that.updateProduct(product);
      });
    }

    function onUnbind(event, ui) {
      var $vendorProductNode = $(ui.draggable),
        vendorProductId = $vendorProductNode.data(dataVendorProductId),
        $product = productFor($vendorProductNode);
      unbind($product, vendorProductId);
      $vendorProductNode
        .css({ top: 0, left: 0, right: 0, bottom: 0, width: 'auto' })
        .prependTo($(vendorProductsTable));
      that.init();
    }

    function onBind(event, ui) {
      var $productNode      = $(this),
        $vendorProductNode  = $(ui.draggable);

      bind($productNode, $vendorProductNode);
      $vendorProductNode.appendTo($productNode.find('ul'));
      that.init();
    }

    this.updateProduct = function (product) {
      var spinner = $('<i/>').addClass(spinnerClass),
        id = product.data(dataProductId),
        url = urlForUpdateProduct(id);
      product
        .find('.panel-heading')
        .prepend(spinner);
      product
        .droppable('disable');
      $.get(url, function (data) {
        product.replaceWith(data);
        that.init();
      });
    };

    this.init = function () {
      $(vendorProduct).draggable(draggableConfig);
      $(productDroppable).droppable(droppableProductConfig);
      $(vendorProductsTable).droppable(droppableVendorProductConfig);
      $("[data-toggle='tooltip']").tooltip({animate: false, html: true});
    };

    $(document).on('click', toScrapeSelector, createFromMarketPlace);
    $(document).on('show.bs.modal', scrapeModal, searchMarketPlace);
    $(document).on('change', updateVendorModel, function () { $(this).closest('form').submit(); });
  }

  window.Kiosk = window.Kiosk || {};
  window.Kiosk.BindingManager = new BindingManager();

}());
