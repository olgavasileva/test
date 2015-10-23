class AddUserAgentForDemographics < ActiveRecord::Migration
  def change
    add_column :demographics, :user_agent, :string
  end
end
