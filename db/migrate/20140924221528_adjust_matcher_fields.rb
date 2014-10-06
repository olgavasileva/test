class AdjustMatcherFields < ActiveRecord::Migration
  def up
    add_column :response_matchers, :type, :string
    add_column :response_matchers, :inclusion, :string
    add_column :response_matchers, :choice_id, :integer, index: true

    remove_column :response_matchers, :include_reponders
    remove_column :response_matchers, :include_skippers
  end

  def down
    remove_column :response_matchers, :type
    remove_column :response_matchers, :inclusion
    remove_column :response_matchers, :choice_id

    add_column :response_matchers, :include_reponders, :boolean
    add_column :response_matchers, :include_skippers, :boolean
  end
end
