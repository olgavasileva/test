class AddTypeToChoices < ActiveRecord::Migration
  def change
    add_column :choices, :type, :string
  end
end
