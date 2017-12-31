function streamWalletsToReloadTable(wallet_addresses, table_id){
  wallet_addresses = wallet_addresses instanceof Array ? wallet_addresses : [wallet_addresses];

  $.each(wallet_addresses, function( index, wallet_address ) {
    App["wallet-"+wallet_address+""] = App.cable.subscriptions.create({channel: "WalletChannel", wallet_address: wallet_address}, 
                                                                    {
                                                                      received: function(data){
                                                                        console.log(data);
                                                                        table_container= $("div#"+table_id+"");
                                                                        if (table_container.length)
                                                                        {
                                                                          reload_path= table_container.attr("data-reload-path");
                                                                          if (reload_path.length)
                                                                          {
                                                                            if (table_container.find("a.reload-table").length == 0) {
                                                                              table_container.append(reload_path);
                                                                            }
                                                                            table_container.find('a.reload-table')[0].click();
                                                                          }
                                                                        }
                                                                      },
                                                                      setWalletAddress: function(wallet_address){
                                                                        this.walletAddress= wallet_address
                                                                      }
                                                                    });
  });
  
}

function streamTotalAccountBalance(account_id, table_id){
  App["balance-"+account_id+""] = App.cable.subscriptions.create({ channel: "BalanceChannel", account_id: account_id },
                                                                  {
                                                                    received: function(data){
                                                                      message = JSON.parse(data.message)
                                                                      console.log(message)
                                                                      $("#total-balance-for-"+account_id+"").text(message.total_balance_xrp)
                                                                      $("#total-pending-received").text(message.wallets_pending_transactions_count)
                                                                      table_container= $("div#"+table_id+"");
                                                                      if (table_container.length)
                                                                      {
                                                                        reload_path= table_container.attr("data-reload-path");
                                                                        if (reload_path.length)
                                                                        {
                                                                          if (table_container.find("a.reload-table").length == 0) {
                                                                            table_container.append(reload_path);
                                                                          }
                                                                          table_container.find('a.reload-table')[0].click();
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                )
}

// stream total balance
$(document).ready(function(){ 
  account_id = $(document).find("body:first").attr("data-account");
  if (account_id != undefined){
    streamTotalAccountBalance(account_id, 'table-container-for-wallets')
  }
});