class AddSpecialCaseAndSponsoredToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :special_case, :boolean, default: false
    add_column :questions, :sponsored, :boolean, default: false
  end
end
