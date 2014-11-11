class AddAllowAnonymousVotesToContest < ActiveRecord::Migration
  def change
    add_column :contests, :allow_anonymous_votes, :boolean, default: false
  end
end
