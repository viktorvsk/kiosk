//= require jquery-ui
//= require jquery.ui.touch-punch.dk
//= require ckeditor/init
//= require jquery.mjs.nestedSortable
//= require select2
//= require select2_locale_ru
//= require_tree ./admin

$(document).ready(function () {

  if($('.binding').size()){
    $(window).scroll(function () {
      if ($(window).scrollTop() > 70 ){
        $('.binding .panel-material').addClass('binding-panel-fixed');
        $('.binding .ul-products').addClass('binding-list-fixed');
      } else {
        $('.binding .panel-material').removeClass('binding-panel-fixed');
        $('.binding .ul-products').removeClass('binding-list-fixed');
      }

    });

  }

  // var defaultRates;
  // defaultRates = {
  //   uah: 1,
  //   usd: 25,
  //   eur: 30,
  //   rrc: 1
  // }
  // defaultRates = JSON.stringify(defaultRates);
  $('.select2').select2();

  // $('.editor').each(function (index, item) {
  //   var lang       = 'json',
  //     editor     = ace.edit(item),
  //     $textarea  = $(item).parent().find('textarea'),
  //     v = JSON.parse($textarea.text() || defaultRates),
  //     pretty = JSON.stringify(v, null, 2);

  //   editor.setValue(pretty);

  //   console.log($textarea);
  //   $textarea.hide();
  //   editor.getSession().setMode('ace/mode/' + lang);
  //   editor.getSession().on('change', function () {
  //     var val = editor.getSession().getValue();
  //     $textarea.text(val);
  //   });
  // });

  $("[data-sortable-taxons]").each(function() {
    $this = $(this);

    return $this.nestedSortable({
      forcePlaceholderSize: true,
      forceHelperSizeType: true,
      errorClass: 'cantdoit',
      disableNesting: 'cantdoit',
      handle: '> .item',
      listType: 'ol',
      items: 'li',
      opacity: .6,
      placeholder: 'placeholder',
      revert: 250,
      maxLevels: 3,
      tabSize: 10,
      protectRoot: $this.data('protect-root'),
      tolerance: 'pointer',
      toleranceElement: '> div',
      isTree: true,
      startCollapsed: false,
      update: function() {
        $this.nestedSortable("disable");
        return $.ajax({
          url: '/admin/taxons/sort',
          type: "post",
          data: $this.nestedSortable("serialize")
        }).always(function() {
          $this.find('.item').each(function(index) {
            if (index % 2) {
              return $(this).removeClass('odd').addClass('even');
            } else {
              return $(this).removeClass('even').addClass('odd');
            }
          });
          $this.nestedSortable("enable");
        }).done(function() {
          return console.log('done');
        }).fail(function() {
          return console.log('fail');
        });
      }
    });
  });


});
