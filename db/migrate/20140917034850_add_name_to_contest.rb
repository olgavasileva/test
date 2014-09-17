class AddNameToContest < ActiveRecord::Migration
  def change
    add_column :contests, :name, :string
  end
end
