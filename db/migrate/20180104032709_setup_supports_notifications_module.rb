class SetupSupportsNotificationsModule < ActiveRecord::Migration[5.1]
  
  def self.up

    create_table :supports_notifications, id: :uuid  do |t|
      t.references :notifiable, polymorphic: true, type: :uuid, index: { name: "supports_notifications_notifiable_type_and_notifiable_id" }
      t.references :sender, polymorphic: true, type: :uuid, index: { name: "supports_notifications_sender" }
      t.string :code
      t.string :subject, default: ""
      t.text :body
      t.string :state
      t.datetime :deleted_at, index: true
      t.string :type
      t.timestamps null: false
    end
    add_index :supports_notifications, :type
    add_index :supports_notifications, :code

    create_table :supports_receipts, id: :uuid do |t|
      t.references :notification, type: :uuid
      t.references :recipient, polymorphic: true, type: :uuid, index: { name: "supports_receipts_recipient" }
      t.string :state
      t.boolean :is_read
      t.boolean :is_trashed
      t.string :mailbox_type
      t.text :options
      t.datetime :scheduled_at
      t.datetime :deleted_at, index: true
      t.string :type
      t.timestamps null: false
    end

    add_index :supports_receipts, :state
    add_index :supports_receipts, :type
    add_index :supports_receipts, :is_trashed
    add_index :supports_receipts, :is_read

  end

  def self.down
    
  end

end
