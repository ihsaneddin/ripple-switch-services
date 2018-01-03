class SetupIpn < ActiveRecord::Migration[5.1]
  
  def self.up
    #
    # create ipn notifications table
    #
    create_table :ipn_notifications, id: :uuid  do |t|
      t.references :notifiable, polymorphic: true, type: :uuid, index: { name: "ipn_notifications_notifiable_type_and_notifiable_id" }
      #t.references :owner, polymorphic: true, type: :uuid, index: { name: "ipn_notifications_owner_type_and_owner_id" }
      t.string :title
      t.text :message
      t.datetime :deleted_at, index: true
      t.string :serializer_class
      t.timestamps null: false
    end

    create_table :ipn_recipients, id: :uuid do |t|
      t.references :notification, type: :uuid
      t.references :recipient, polymorphic: true, type: :uuid, index: { name: "ipn_recipients_recipient_type_and_recipient_id" }
      t.string :state
      t.integer :retry, default: 0
      t.integer :retry_count, default: 0
      t.string :result
      t.datetime :scheduled_at
      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end

    #add_index :ipn_recipients, :notification_id
    add_index :ipn_recipients, :state

  end

  def self.down
    drop_table :ipn_notifications
    drop_table :ipn_recipients
  end

end
