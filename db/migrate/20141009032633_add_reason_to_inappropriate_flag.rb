class AddReasonToInappropriateFlag < ActiveRecord::Migration
  def change
    add_column :inappropriate_flags, :reason, :text
  end
end
