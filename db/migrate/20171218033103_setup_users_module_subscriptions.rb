class SetupUsersModuleSubscriptions < ActiveRecord::Migration[5.1]
  
  def self.up

    #
    # create plans table
    #
    create_table :users_plans, id: :uuid  do |t|
      t.string :name
      t.text :features
      t.text :description
      t.decimal :price, :default => 0.0, :precision => 15, :scale => 2
      t.string :currency
      t.integer :display_order
      t.string :state
      t.boolean :free, default: false
      t.string :per_period, default: "month"

      t.datetime :deleted_at, index: true

      t.timestamps null: false
    end

    add_index :users_plans, :name
    add_index :users_plans, :price

    #
    # create subscriptions table
    #
    create_table :users_subscriptions, id: :uuid do |t|
      t.string :name
      t.uuid :account_id
      t.uuid :plan_id
      t.decimal :amount, :precision => 50, :scale => 35, default: 0
      t.string :coin
      t.datetime :expired_at
      t.string :state
      t.string :txn_id
      t.string :qrcode_url
      t.string :status_url
      t.string :payment_address
      t.string :notification_email

      t.datetime :deleted_at, index: true

      t.timestamps null: false
    end

    add_index :users_subscriptions, :name
    add_index :users_subscriptions, :account_id
    add_index :users_subscriptions, :plan_id
    add_index :users_subscriptions, :expired_at

  end

  def self.down
    drop_table :users_plans
    drop_table :users_subscriptions
  end

end
