class AddResolvedToAlerts < ActiveRecord::Migration[5.2]
  def change
    add_column :cyber_adapt_alerts, :resolved, :boolean, default: false
  end
end
