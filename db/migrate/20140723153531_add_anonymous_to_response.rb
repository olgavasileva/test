class AddAnonymousToResponse < ActiveRecord::Migration
  def change
    add_column :responses, :anonymous, :boolean
  end
end
