(function () {

  $(document).ready(function () {

    // $('.product-cover').magnificPopup({
    //   type: 'image',
    //   closeOnContentClick: true,
    //   closeBtnInside: false,
    //   fixedContentPos: true,
    //   mainClass: 'mfp-no-margins mfp-with-zoom', // class to remove default margin from left and right side
    //   image: {
    //     verticalFit: true
    //   },
    //   zoom: {
    //     enabled: true,
    //     duration: 300 // don't foget to change the duration also in CSS
    //   }
    // });

    $('.product_card').magnificPopup({
      delegate: '.mfp-gallery',
      type: 'image',
      tLoading: 'Загрузка #%curr%...',
      mainClass: 'mfp-img-mobile',
      zoom: {
        enabled: true,
        duration: 300 // don't foget to change the duration also in CSS
      },
      gallery: {
        enabled: true,
        navigateByImgClick: true,
        preload: [0, 1] // Will preload 0 - before current, and 1 after the current image
      },
      image: {
        tError: '<a href="%url%">Изображение #%curr%</a> не загружено',
        titleSrc: function (item) {
          return item.el.attr('title');
        }
      }
    });


    // $('.images-thumbs').magnificPopup({
    //   delegate: 'a',
    //   type: 'image',
    //   tLoading: 'Загрузка #%curr%...',
    //   mainClass: 'mfp-img-mobile',
    //   zoom: {
    //     enabled: true,
    //     duration: 300 // don't foget to change the duration also in CSS
    //   },
    //   gallery: {
    //     enabled: true,
    //     navigateByImgClick: true,
    //     preload: [0, 1] // Will preload 0 - before current, and 1 after the current image
    //   },
    //   image: {
    //     tError: '<a href="%url%">Изображение #%curr%</a> не загружено',
    //     titleSrc: function (item) {
    //       return item.el.attr('title');
    //     }
    //   }
    // });
  });

}());
