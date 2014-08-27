class CreateLikedComments < ActiveRecord::Migration
  def change
    create_table :liked_comments do |t|
      t.references :user, index: true
      t.references :response, index: true

      t.timestamps
    end
  end
end
