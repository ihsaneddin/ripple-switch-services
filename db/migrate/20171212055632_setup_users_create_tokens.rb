class SetupUsersCreateTokens < ActiveRecord::Migration[5.1]
  
  def self.up
    create_table :users_tokens, id: :uuid  do |t|
      ## Database authenticatable
      t.string :token
      t.uuid :account_id
      t.datetime :expired_at, null: false

      t.datetime :deleted_at, index: true
      
      t.timestamps null: false
    end

    add_index :users_tokens, :token
    add_index :users_tokens, :account_id

    add_column :users_accounts, :token, :string
    add_column :users_accounts, :encrypted_pin, :string
    add_column :users_accounts, :encrypted_pin_iv, :string

    add_index :users_accounts, :token, unique: true
  end

  def self.down
    drop_table :users_tokens
    remove_index :users_accounts, :token
  end
end
