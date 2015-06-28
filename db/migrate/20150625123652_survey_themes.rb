class SurveyThemes < ActiveRecord::Migration
  def up
    theme_id = if Object.const_defined? 'EmbeddableUnitTheme'
                 EmbeddableUnitTheme.find_by(title: EmbeddableUnitTheme::DEFAULT_THEME, user: nil).id
               else
                 1
               end
    add_column :surveys, :theme_id, :integer, null: false, default: theme_id
  end

  def down
    remove_column :surveys, :theme_id
  end
end
