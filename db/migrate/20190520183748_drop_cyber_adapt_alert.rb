class DropCyberAdaptAlert < ActiveRecord::Migration[5.2]
  def change
    drop_table :cyber_adapt_alerts
  end
end
