class AddOriginalReferrerToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :original_referrer, :text
  end
end
