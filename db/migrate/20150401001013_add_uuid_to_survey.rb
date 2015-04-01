class AddUuidToSurvey < ActiveRecord::Migration
  def up
    add_column :surveys, :uuid, :string
    add_index :surveys, :uuid

    begin
      Survey.reset_column_information
      Survey.all.find_each do |s|
        s.update_attribute :uuid, "S"+UUID.new.generate.gsub(/-/, '')
      end
    rescue
      # in case Comment isn't around some day
    end
  end

  def down
    remove_column :surveys, :uuid
  end
end
