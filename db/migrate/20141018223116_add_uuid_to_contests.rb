class AddUuidToContests < ActiveRecord::Migration
  def change
    add_column :contests, :uuid, :string
  end
end
