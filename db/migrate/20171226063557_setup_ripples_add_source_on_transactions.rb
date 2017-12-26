class SetupRipplesAddSourceOnTransactions < ActiveRecord::Migration[5.1]
  
  def self.up
    add_column :ripples_transactions, :source, :string
    add_index :ripples_transactions, :source
  end

  def self.down
    remove_index :ripples_transactions, :source
    remove_column :ripples_transactions, :source  
  end

end
