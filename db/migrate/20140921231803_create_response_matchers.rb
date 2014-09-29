class CreateResponseMatchers < ActiveRecord::Migration
  def change
    create_table :response_matchers do |t|
      t.references :segment, index: true
      t.references :question, index: true
      t.boolean :include_reponders
      t.boolean :include_skippers
      t.text :regex
      t.integer :first_place_choice_id

      t.timestamps
    end
  end
end
