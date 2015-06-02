class ThankYouDefault < ActiveRecord::Migration
  def change
    add_column :surveys, :thank_you_default, :boolean, default: false, null: false
  end
end
