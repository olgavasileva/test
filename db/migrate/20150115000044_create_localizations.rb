class CreateLocalizations < ActiveRecord::Migration
  def change
    create_table :localizations do |t|
      t.references :language, index: true
      t.integer :localizable_id
      t.string :localizable_type

      t.timestamps
    end
  end
end
