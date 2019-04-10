class AddDhcpLeases < ActiveRecord::Migration[5.2]
  def up
    remove_column :machines, :ip
    remove_column :uri_entries, :machine_id

    create_table :dhcp_leases do |t|
      t.inet :ip, null: false
      t.references :machine
      t.references :paper_trail, null: false
      t.timestamps
    end

    add_reference :uri_entries, :dhcp_lease
  end

  def down
    add_column :machines, :ip, :inet
    add_reference :uri_entries, :machine
    drop_table :dhcp_leases
  end
end
