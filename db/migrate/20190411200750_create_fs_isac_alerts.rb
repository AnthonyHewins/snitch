class CreateFsIsacAlerts < ActiveRecord::Migration[5.2]
  def change
    create_table :fs_isac_alerts do |t|
      t.string :title, null: false
      t.bigint :tracking_id, null: false
      t.datetime :alert_timestamp, null: false
      t.text :alert, null: false
      t.text :affected_products, null: false
      t.text :corrective_action, null: false
      t.text :sources, null: false
      t.boolean :resolved, default: false
      t.text :comment

      t.timestamps
    end
  end
end
