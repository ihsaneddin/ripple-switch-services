class SetupAdminModule < ActiveRecord::Migration[5.1]
  def self.up

    #
    # create admin table
    #
    create_table :administration_admins, id: :uuid  do |t|
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

    add_index :administration_admins, :email,                unique: true
    add_index :administration_admins, :username,                unique: true
    add_index :administration_admins, :reset_password_token, unique: true
    add_index :administration_admins, :confirmation_token,   unique: true
    add_index :administration_admins, :unlock_token,         unique: true
    add_index :administration_admins, :token, unique: true

  end

  def self.down
    drop_table :administration_admins
  end
end
