class AddResponsesIndexes < ActiveRecord::Migration
  def change
    add_index :responses, :original_referrer, length: 200
    add_index :listicle_responses, :original_referrer, length: 200
    add_index :responses, :created_at
    add_index :listicle_responses, :created_at
  end
end
