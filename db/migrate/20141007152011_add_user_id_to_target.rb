class AddUserIdToTarget < ActiveRecord::Migration
  def change
    add_reference :targets, :user, index: true
  end
end
