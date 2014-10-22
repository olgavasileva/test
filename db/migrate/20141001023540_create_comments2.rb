class CreateComments2 < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :body
      t.references :user, index: true
      t.references :question, index: true
      t.references :parent, index: true

      t.timestamps
    end
  end
end
