(function () {
  function setFilterValue() {
    var url = $(this).data('pfv'),
      filterValue = $(this).val();
    $.ajax({
      url: url,
      method: 'PATCH',
      data: { 'new_id': filterValue }
    });
  }

  $('[data-pfv]').change(setFilterValue);
}());
