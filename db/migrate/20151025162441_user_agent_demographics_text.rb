class UserAgentDemographicsText < ActiveRecord::Migration
  def change
    change_column :demographics, :user_agent, :text
  end
end
