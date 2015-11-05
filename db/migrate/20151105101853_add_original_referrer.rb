class AddOriginalReferrer < ActiveRecord::Migration
  def change
    add_column :listicle_responses, :original_referrer, :string
  end
end
