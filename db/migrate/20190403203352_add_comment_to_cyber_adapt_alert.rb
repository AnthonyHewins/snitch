class AddCommentToCyberAdaptAlert < ActiveRecord::Migration[5.2]
  def change
    add_column :cyber_adapt_alerts, :comment, :text
  end
end
