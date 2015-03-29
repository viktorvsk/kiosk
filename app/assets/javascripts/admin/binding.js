/*jslint browser: true */

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
  this.activationClass      = '[data-activation-toggle]';

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

  // this.findProduct = function (id) {
  //   var selector = ['[data-product-id="', id, '"]'].join('');
  //   return $(selector);
  // };

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
    // $(that.activationClass).on('ajax:success', function(evt, data, status, xhr) {
    //   $(this).closest('li').addClass(data);
    //   console.log(data);
    // });
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
    var id = vendorProduct.data('vendor-product-id');

    return $('li[data-product-id="' + id + '"]');
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
      .css({ top: 0, left: 0, right: 0, bottom: 0 })
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

window.Binding = new Binding();

