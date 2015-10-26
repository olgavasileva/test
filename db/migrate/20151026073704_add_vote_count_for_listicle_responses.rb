class AddVoteCountForListicleResponses < ActiveRecord::Migration
  def change
    add_column :listicle_responses, :vote_count, :integer, null: false, default: 1
  end
end
