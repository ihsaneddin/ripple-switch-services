class SetupSettingable < ActiveRecord::Migration[5.1]
  
  def self.up
    
    create_table :settingable_settings, id: :uuid do |t|
      t.string :name
      t.references :settingable, polymorphic: true, index: { name: "settingable_settings_type_and_setingable_id" }, type: :uuid
      #t.string :settingable_type
      #t.uuid :settingable_id, index: true
      t.text :options
      t.datetime :deleted_at, index: true

      t.timestamps null: false
    end

  end

  def self.down
    drop :settingable_settings
  end

end
