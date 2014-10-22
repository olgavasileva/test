class RemoveResponseIdFromLikedComments < ActiveRecord::Migration
  def change
    remove_reference :liked_comments, :response, index: true
  end
end
