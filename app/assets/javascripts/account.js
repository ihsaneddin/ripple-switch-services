// This is a manifest file that'll be compiled into admin.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require rails-ujs
//= require turbolinks
//= require bootstrap/js/bootstrap
//= require raphael/raphael
//= require morris/morris
//= require sparkline/jquery.sparkline
//= require jvectormap/jquery-jvectormap-1.2.2.min
//= require jvectormap/jquery-jvectormap-world-mill-en
//= require knob/jquery.knob
//= require moment/moment
//= require daterangepicker/daterangepicker
//= require datepicker/bootstrap-datepicker
//= require bootstrap-wysihtml5/bootstrap3-wysihtml5.all
//= require slimScroll/jquery.slimscroll
//= require fastclick/fastclick
//= require adminLTE/js/app
//= require iCheck/icheck
//= require notify/notify.min
//= require iodash
//= require ripple.min
//= require custom
//= require wallet


$(document).ready(function(){

  $('.fa-sign-out').closest('a').attr('data-method', 'true');

  // toggle alement
  $('body').on("click", '.toggle', function(e){

    $(this).addClass('hidden');
    $($(this).attr('data-toggle')).removeClass('hidden');

  });

});