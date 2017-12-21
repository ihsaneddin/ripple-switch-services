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
//= require ripple_client
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
//= require Chart.bundle
//= require highcharts/highcharts
//= require chartkick
//= require iodash
//= require ripple.min
//= require custom
//= require wallet
//= require data-confirm

(function(){
  // always pass csrf tokens on ajax calls
  $.ajaxSetup({
    headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') }
  });



});

$(function () {
                $('.pick-a-date').datepicker({
                  autoclose: true,
                  format: "dd-mm-yyyy"
                });
            });


$(function(){
  $(".wysihtml5").wysihtml5({"html": true});
})

$(document).ready(function(){

  $('.fa-sign-out').closest('a').attr('data-method', 'delete');

  // toggle alement
  $(document).on("click", '.toggle', function(e){

    console.log("asup")

    $(this).addClass('hidden');
    $($(this).attr('data-toggle')).removeClass('hidden');

  });

});
