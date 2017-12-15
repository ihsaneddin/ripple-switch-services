

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

function completeTransaction(address, tx_hash){
  if ($("body div#complete-links").length == 0)
  {
    $('body').append("<div id='complete-links'></div>");
  }
  var link;
  proto = $("#proto-complete-transaction")
  if (proto.length){
    href = proto.attr('href');
    href = href.replace("wallet_id", address);
    href = href.replace("tx_hash", tx_hash);
    link = proto.clone()
    
    $("body div#complete-links").append(link);
    link = $("body div#complete-links a").last();
    link.attr("id", "complete-"+address+"-"+tx_hash+"");
    link.attr("href", href);

  }else{
    url = "/ripple/wallets/"+address+"/transactions/"+tx_hash+"/complete";
    link = "<a href='"+url+"' class='btn btn-default btn-lg' data-remote='true' data-method='put' id='complete-transaction'>Complete</a>"
    $("body div#complete-links").append(link);
  }
  link[0].click();
}