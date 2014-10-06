class CreateContestResponseVotes < ActiveRecord::Migration
  def change
    create_table :contest_response_votes do |t|
      t.references :contest, index: true
      t.references :response, index: true
      t.integer :vote_count

      t.timestamps
    end
  end
end
