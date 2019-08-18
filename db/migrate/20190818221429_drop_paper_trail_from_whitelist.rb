class DropPaperTrailFromWhitelist < ActiveRecord::Migration[5.2]
  def change
    remove_column :whitelists, :paper_trail_id
  end
end
