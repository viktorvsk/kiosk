// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require jquery-ui/ui/core
//= require jquery-ui/ui/widget
//= require jquery-ui/ui/mouse
//= require jquery-ui/ui/draggable
//= require jquery-ui/ui/droppable
//= require admin/binding

$(document).on('click', '[data-toggler]', function (event) {
  var attr = $(this).data('toggler'),
    selector = '[data-toggleable="' + attr + '"]',
    $node = $(selector),
    visible = $node.css('display') === 'block';
  if (visible) {
    $(this).text('Показать фильтры');
  } else {
    $(this).text('Скрыть фильтры');
  }
  $node.fadeToggle(100);
  event.preventDefault();
});
