class CreateTargetsUsers < ActiveRecord::Migration
  def change
    create_table :targets_users do |t|
      t.references :user, index: true
      t.references :target, index: true

      t.timestamps
    end
  end
end
