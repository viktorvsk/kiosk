/*jslint browser:true */
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
//= require jquery-ui/ui/position
//= require jquery-ui/ui/menu
//= require jquery-ui/ui/mouse
//= require jquery-ui/ui/draggable
//= require jquery-ui/ui/droppable
//= require jquery-ui/ui/sortable

//= require jquery-ui/ui/autocomplete
//= require_tree ./admin
//= require_self

window.Kiosk = window.Kiosk || {};
$(document).on('click', '[data-toggler]', window.Kiosk.Common.toggler);
$(document).on('ajaxSend', window.Kiosk.Common.startLoading);
$(document).on('ajaxComplete', window.Kiosk.Common.finishLoading);
