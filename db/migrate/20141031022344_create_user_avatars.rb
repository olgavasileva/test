class CreateUserAvatars < ActiveRecord::Migration
  def change
    create_table :user_avatars do |t|
      t.string :image

      t.timestamps
    end
  end
end
