class AddDhcpLeases < ActiveRecord::Migration[5.2]
  def change
    create_table :dhcp_leases do |t|
      t.inet :ip, null: false
      t.references :machine
      t.references :paper_trail, null: false
      t.timestamps
    end
  end
end
