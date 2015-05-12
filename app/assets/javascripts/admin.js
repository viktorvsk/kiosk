//= require jquery-ui/ui/core
//= require jquery-ui/ui/widget
//= require jquery-ui/ui/position
//= require jquery-ui/ui/menu
//= require jquery-ui/ui/mouse
//= require jquery-ui/ui/draggable
//= require jquery-ui/ui/droppable
//= require jquery-ui/ui/sortable
//= require jquery.ui.touch-punch.dk
//= require ckeditor/init

//= require jquery-ui/ui/autocomplete
//= require ace/ace
//= require ace/worker-html
//= require ace/worker-json
//= require ace/theme-monokai
//= require ace/mode-json
//= require select2
//= require select2_locale_ru
//= require_tree ./admin

$(document).ready(function () {
  var defaultRates;
  defaultRates = {
    uah: 1,
    usd: 25,
    eur: 30,
    rrc: 1
  }
  defaultRates = JSON.stringify(defaultRates);
  $('.select2').select2();

  $('.editor').each(function (index, item) {
    var lang       = 'json',
      editor     = ace.edit(item),
      $textarea  = $(item).parent().find('textarea'),
      v = JSON.parse($textarea.text() || defaultRates),
      pretty = JSON.stringify(v, null, 2);

    editor.setValue(pretty);

    console.log($textarea);
    $textarea.hide();
    editor.getSession().setMode('ace/mode/' + lang);
    editor.getSession().on('change', function () {
      var val = editor.getSession().getValue();
      $textarea.text(val);
    });
  });
});
