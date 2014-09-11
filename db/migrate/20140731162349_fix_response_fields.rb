class FixResponseFields < ActiveRecord::Migration
  def up
    remove_column :responses, :stars
    remove_column :responses, :percent
    remove_column :responses, :position

    add_column :order_choices_responses, :position, :integer
    add_column :star_choices_responses, :stars, :integer
    add_column :percent_choices_responses, :percent, :float
  end

  def down
    add_column :responses, :stars, :integer
    add_column :responses, :percent, :float
    add_column :responses, :position, :integer

    remove_column :order_choices_responses, :position
    remove_column :star_choices_responses, :stars
    remove_column :percent_choices_responses, :percent
  end
end
