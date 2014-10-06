class CreateSkips < ActiveRecord::Migration
  def change
    create_table :skipped_items do |t|
      t.references :user, index: true
      t.references :question, index: true

      t.timestamps
    end
  end
end
