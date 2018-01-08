class SetupEncryptedRequests < ActiveRecord::Migration[5.1]

  def self.up

    create_table :supports_encrypted_requests, id: :uuid do |t|
      t.references :requester, polymorphic: true, type: :uuid, index: { name: "supports_encrypted_requests_requester" }
      t.references :context, polymorphic: true, type: :uuid, index: { name: "supports_encrypted_requests_context" }
      t.text :encrypted_data
      t.string :state
      t.datetime :expired_at
      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end

  end

  def self.down
    drop_table :supports_encrypted_requests
  end

end
