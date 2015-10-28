class AddScoreToListicleResponses < ActiveRecord::Migration
  def change
    add_column :listicle_responses, :score, :integer, null: false, default: 0
  end
end
