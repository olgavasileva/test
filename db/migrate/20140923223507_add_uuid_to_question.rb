class AddUuidToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :uuid, :string
  end
end
