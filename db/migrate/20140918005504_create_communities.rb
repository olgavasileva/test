class CreateCommunities < ActiveRecord::Migration
  def change
    create_table :communities do |t|
      t.string :name
      t.boolean :private, default: false
      t.string :password
      t.string :password_confirmation
      t.text :description
      t.references :user, index: true

      t.timestamps
    end
  end
end
