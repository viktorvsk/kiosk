Binding = {
  init: function () {
    $(Binding.selector.vendorProduct).draggable({ revert: 'invalid' });

    $(Binding.selector.product).droppable({
      hoverClass: 'test',
      cursorAt: { top: -5, left: -5 },
      disabled: false,
      drop: Binding.onBind
    });

    $(Binding.selector.vendorProductsTable).droppable({
      hoverClass: 'test',
      drop: Binding.onUnbind
    })
  },
  bind: function (url) {
    $.post(url);
  },
  unbind: function(url) {
    $.ajax({
      url: url,
      type: 'DELETE'
    });
  },
  selector: {
    vendorProduct: '[data-draggable="vendorProduct"]',
    product: '[data-droppable="product"]',
    vendorProductsTable: '[data-droppable="vendorProductsTable"]'
  },
  data: {
    vendorProductId: 'vendor-product-id',
    productId: 'product-id'
  },
  url: {
    binding: function (product, vendorProduct) {
      return ['/admin', 'binding', product, vendorProduct].join('/');
    },
    unbinding: function (vendorProduct) {
      return ['/admin', 'binding', vendorProduct].join('/');
    }
  },
  onUnbind: function (event, ui) {
    var $vendorProductNode  = $(ui.draggable),
        vendorProductId     = $vendorProductNode.data(Binding.data.vendorProductId);;
    Binding.unbind(Binding.url.unbinding(vendorProductId));
    $vendorProductNode.remove();
    $("form").submit()
    Binding.init();

  },
  onBind: function ( event, ui ) {
    var $productNode        = $(this),
        $vendorProductNode  = $(ui.draggable),
        productId           = $productNode.data(Binding.data.productId),
        vendorProductId     = $vendorProductNode.data(Binding.data.vendorProductId);

    // $vendorProduct = $('<li>')
    //                   .text($vendorProductNode.text())
    //                   .attr('data-draggable', 'vendorProduct')
    //                   .attr('data-vendor-product-id', vendorProductId);
    // $productNode
    //   .find('ul')
    //     .append($vendorProduct);

    Binding.bind(Binding.url.binding(productId, vendorProductId));
    $vendorProductNode.remove();
    $("form").submit()
    Binding.init();

  }
};
