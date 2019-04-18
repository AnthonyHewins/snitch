class AddAppliesToFsIsacAlert < ActiveRecord::Migration[5.2]
  def change
    add_column :fs_isac_alerts, :applies, :boolean, default: true

    create_table :fs_isac_ignore do |t|
      t.string :regex_string, null: false
      t.boolean :case_sensitive, default: false
    end
  end
end
