class AddUserIdToSurveys < ActiveRecord::Migration
  def up
    # add_column :surveys, :user_id, :integer

    say_with_time "Setting user_id on existing Survey records" do
      Survey.find_each do |survey|
        if user_id = survey.questions.first.try(:user_id)
          survey.update_attribute :user_id, user_id
        end
      end
    end

    say_with_time "Destroying orphaned Survey records" do
      query = Survey.where(user_id: nil)
      query.count.tap { query.destroy_all }
    end

    change_column :surveys, :user_id, :integer, null: false
    add_index :surveys, :user_id
  end

  def down
    remove_index :surveys, :user_id
    remove_column :surveys, :user_id
  end
end
