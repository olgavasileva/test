class AddRedirectAttributesToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :redirect, :string
    add_column :surveys, :redirect_url, :string
    add_column :surveys, :redirect_timeout, :integer

    add_index :surveys, :redirect
  end
end
