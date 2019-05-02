class AddDepartmentToMachines < ActiveRecord::Migration[5.2]
  def change
    create_table :departments do |t|
      t.string :name
    end

    add_reference :machines, :department
  end
end
