class SetupRipples < ActiveRecord::Migration[5.1]
  
  def self.up

    #
    # create wallet table
    #
    create_table :ripples_wallets, id: :uuid  do |t|
      t.uuid :account_id
      t.integer :sequence
      t.string :label
      t.string :address
      t.string :encrypted_secret
      t.string :encrypted_secret_iv
      t.string :seed
      t.boolean :validated, default: false
      t.decimal :balance, :default => 0.0, :precision => 15, :scale => 2
      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end

    add_index :ripples_wallets, :account_id
    add_index :ripples_wallets, :label
    add_index :ripples_wallets, :validated
    add_index :ripples_wallets, :address, unique: true


    #
    # create transactions table
    #
    create_table :ripples_transactions, id: :uuid do |t|
      t.uuid :wallet_id
      t.string :destination
      t.string :tx_hash, unique: true
      t.decimal :amount, :default => 0.0, :precision => 15, :scale => 2
      t.string :source_currency
      t.string :destination_currency
      t.string :state
      t.string :transaction_type
      t.integer :transaction_date
      t.datetime :deleted_at, index: true
      t.boolean :validated, default: false
      t.timestamps null: false
    end

    add_index :ripples_transactions, :wallet_id
    add_index :ripples_transactions, :tx_hash
    add_index :ripples_transactions, :destination

  end

  def self.down
    drop_table :ripples_wallets
    drop_table :ripples_transactions
  end

end
