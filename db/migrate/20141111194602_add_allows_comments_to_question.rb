class AddAllowsCommentsToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :require_comment, :boolean, default: false
  end
end
