class AddBirthDateAndGenderToUsers < ActiveRecord::Migration
  def change
    add_column :users, :birthdate, :date
    add_column :users, :gender, :string
  end
end
