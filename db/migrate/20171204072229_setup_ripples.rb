class SetupRipples < ActiveRecord::Migration[5.1]
  
  def self.up

    #
    # create wallet table
    #
    create_table :ripples_wallets, id: :uuid  do |t|
      t.uuid :account_id, index: true
      t.integer :sequence
      t.string :label, index: true
      t.string :encrypted_address
      t.string :encrypted_address_iv
      t.string :encrypted_secret
      t.string :encrypted_secret_iv
      t.string :seed
      t.boolean :validated, default: false
      t.decimal :balance, :default => 0.0, :precision => 15, :scale => 2
      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end

  end

  def self.down
    drop_table :ripples_wallets  
  end

end
