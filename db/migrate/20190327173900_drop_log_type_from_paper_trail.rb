class DropLogTypeFromPaperTrail < ActiveRecord::Migration[5.2]
  def change
    remove_column :paper_trails, :log_type
  end
end
