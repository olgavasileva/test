class AddNameToPartner < ActiveRecord::Migration
  def change
    add_column :partners, :name, :string
  end
end
