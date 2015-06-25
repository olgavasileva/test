class CreateEmbeddableUnitThemes < ActiveRecord::Migration
  def up
    create_table :embeddable_unit_themes do |t|
      t.string :title, null: false
      t.string :main_color, null: false
      t.string :color1, null: false
      t.string :color2, null: false
      t.integer :user_id
    end
    if Object.const_defined? 'EmbeddableUnitTheme'
      EmbeddableUnitTheme.create title: 'statisfy', main_color: '#F1F3F2', color1: '#2E92D6', color2: '#FDAD4C'
    end
  end

  def down
    drop_table :embeddable_unit_themes
  end
end
