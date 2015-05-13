/*jslint browser:true*/
(function () {
  $(document).ready(function () {

    $('#instant-checkout').on('shown.bs.modal', function () {
      $(".modal .lazy").lazyload();
    });

  });
}());
