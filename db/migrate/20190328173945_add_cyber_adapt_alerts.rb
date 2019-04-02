class AddCyberAdaptAlerts < ActiveRecord::Migration[5.2]
  def change
    create_table :cyber_adapt_alerts do |t|
      t.integer :alert_id, null: false, unique: true
      t.text :alert
      t.string :msg
      t.inet :src_ip, null: false
      t.inet :dst_ip, null: false
      t.integer :src_port, null: false
      t.integer :dst_port, null: false
      t.datetime :alert_timestamp, null: false
      t.timestamps
    end
  end
end
