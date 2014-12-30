class CreateEmbeddableUnits < ActiveRecord::Migration
  def change
    create_table :embeddable_units do |t|
      t.string :uuid
      t.references :survey, index: true

      t.timestamps
    end
  end
end
