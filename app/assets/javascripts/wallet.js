var rippleClient = new ripple.RippleAPI({server:'wss://s.altnet.rippletest.net:51233'});

function fillTableAddresses(addresses){
  $.each( addresses, function( i, address ) {
    rippleClient.connect().then(() => {
      rippleClient.getAccountInfo(address).then( info => {
        
        tr = $('#td-'+address+'-balance').closest('tr')
        if (tr.length)
        {
          $('#td-'+address+'-balance').text(info.xrpBalance);
          if (tr.hasClass('inactive')){
            tr.append(tr.attr('data-active'));
            $('#status-'+address+'-address').html('<span class="label label-info" title="Your wallet is active">active</span>');
            tr.find('a.activate')[0].click();
          }

          //rippleClient.getTransactions(address, { "counter_party": true, limit: 20 }).then(transaction => {
          //  console.log(transaction);
          //});

        }
      })//.then(() => {return rippleClient.disconnect()});
    });         
  });
}

