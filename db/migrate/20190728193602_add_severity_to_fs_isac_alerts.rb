class AddSeverityToFsIsacAlerts < ActiveRecord::Migration[5.2]
  def change
    add_column :fs_isac_alerts, :severity, :integer
  end
end
