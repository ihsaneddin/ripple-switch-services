var rippleWS, rippleClient;

//$(document).on('turbolinks:load', function(){
$(document).ready(function(){
  // get ws url from rails
  wsUrl = $(document).find("body:first").attr("data-rails-ws")
  if (wsUrl != undefined){
    rippleWS = wsUrl; 
    rippleClient = new ripple.RippleAPI({server: rippleWS});
  }
})