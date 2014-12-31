class AddSizeToEmbeddableUnit < ActiveRecord::Migration
  def change
    add_column :embeddable_units, :width, :integer
    add_column :embeddable_units, :height, :integer
  end
end
