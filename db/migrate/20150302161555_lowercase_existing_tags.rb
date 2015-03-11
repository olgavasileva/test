class LowercaseExistingTags < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute('UPDATE tags SET name = LOWER(name)')
      end
    end
  end
end
