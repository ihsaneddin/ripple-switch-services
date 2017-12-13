class SetupUsersModule < ActiveRecord::Migration[5.1]
  def self.up

    enable_extension 'uuid-ossp'
    enable_extension 'pgcrypto'

    #
    # create users table
    #
    create_table :users_accounts, id: :uuid  do |t|
      ## Database authenticatable
      t.string :username
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      t.string   :token
      t.string :encrypted_pin
      t.string :encrypted_pin_iv

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      t.datetime :deleted_at, index: true

      t.timestamps null: false
    end

    add_index :users_accounts, :email,                unique: true
    add_index :users_accounts, :username,                unique: true
    add_index :users_accounts, :reset_password_token, unique: true
    add_index :users_accounts, :confirmation_token,   unique: true
    add_index :users_accounts, :unlock_token,         unique: true
    add_index :users_accounts, :token, unique: true

    # create tokens table
    create_table :users_tokens, id: :uuid  do |t|
      t.string :token
      t.uuid :account_id
      t.datetime :expired_at, null: false

      t.datetime :deleted_at, index: true
      
      t.timestamps null: false
    end

    add_index :users_tokens, :token
    add_index :users_tokens, :account_id

  end

  def self.down
    drop_table :users_accounts
    drop_table :users_tokens
  end

end
