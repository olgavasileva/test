class AddAllToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :kind, :string
    add_index :questions, :kind
  end
end
