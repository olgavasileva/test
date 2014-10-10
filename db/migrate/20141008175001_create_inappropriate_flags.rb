class CreateInappropriateFlags < ActiveRecord::Migration
  def change
    create_table :inappropriate_flags do |t|
      t.references :question, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
