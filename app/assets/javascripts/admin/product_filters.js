(function () {
  $('[data-pfv]').change(function () {
    var pf = $(this).data('pfv'),
      filterValue = $(this).val();
    console.log(pf, filterValue);
  });
}());
