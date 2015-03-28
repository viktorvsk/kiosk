/*jslint browser: true */
(function () {
  function Binding() {
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

    this.urlForBind = function (product, vendorProduct) {
      return ['/admin', 'binding', product, vendorProduct].join('/');
    };

    this.urlForUnbind = function (vendorProduct) {
      return ['/admin', 'binding', vendorProduct].join('/');
    };

    this.urlForRecountProduct = function (id) {
      return ['/admin', 'products', id, 'recount'].join('/');
    };

    this.urlForUpdateProduct = function (id) {
      return ['/admin', 'products', id].join('/');
    };

    // this.findProduct = function (id) {
    //   var selector = ['[data-product-id="', id, '"]'].join('');
    //   return $(selector);
    // };

    this.updateProduct = function ($product) {
      var spinner = $('<i/>').addClass(that.spinnerClass),
        id = $product.data(that.dataProductId),
        url = that.urlForUpdateProduct(id);
      $product
        .prepend(spinner)
        .droppable('disable');
      $.get(url, function (data) {
        $product.replaceWith(data);
        that.init();
      });

    };

    this.bindFromProduct = function ($vendorProduct) {
      return $vendorProduct.parent().parent().data('droppable') === 'product';
    };

    this.init = function () {
      $(that.vendorProduct).draggable(that.draggableConfig);
      $(that.product).droppable(that.droppableProductConfig);
      $(that.vendorProductsTable).droppable(that.droppableVendorProductConfig);
    };

    this.bind = function (product, vendorProduct) {
      var url = that.urlForBind(product, vendorProduct);
      $.post(url);
    };

    this.productFor = function ($vendorProduct) {
      return $vendorProduct.parent().parent();
    };

    this.unbind = function (vendorProduct) {
      var url = that.urlForUnbind(vendorProduct);
      $.ajax({
        url: url,
        type: 'DELETE'
      });
    };

    this.recountProduct = function ($product) {
      var id = $product.data(that.dataProductId),
        url = that.urlForRecountProduct(id);
      $.post(url, function (data) {
        that.updateProduct($product);
        console.log(data);
      });
    };

    this.onUnbind = function (event, ui) {
      var $vendorProductNode = $(ui.draggable),
        vendorProductId = $vendorProductNode.data(that.dataVendorProductId),
        $product = that.productFor($vendorProductNode);
      that.unbind(vendorProductId);
      $vendorProductNode
        .css({ top: 0, left: 0, right: 0, bottom: 0 })
        .prependTo($(that.vendorProductsTable));
      that.updateProduct($product);
      that.init();
    };

    this.onBind = function (event, ui) {
      var $productNode      = $(this),
        $oldProduct         = null,
        $vendorProductNode  = $(ui.draggable),
        productId           = $productNode.data(that.dataProductId),
        vendorProductId     = $vendorProductNode.data(that.dataVendorProductId);

      that.bind(productId, vendorProductId);
      if (that.bindFromProduct($vendorProductNode)) {
        $oldProduct = that.productFor($vendorProductNode);
      }
      $vendorProductNode.remove();
      that.updateProduct($productNode);
      that.recountProduct($oldProduct);

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

  window.Binding = new Binding();
}());
