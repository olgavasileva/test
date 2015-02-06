class AddIndexToInstanceAuthToken < ActiveRecord::Migration
  def change
    add_index :instances, :auth_token
  end
end
