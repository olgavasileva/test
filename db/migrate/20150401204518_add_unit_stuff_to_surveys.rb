class AddUnitStuffToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :thank_you_markdown, :text
    add_column :surveys, :thank_you_html, :text

    reversible do |dir|
      dir.up do
        say_with_time "Ensuring all Survey records have uuid" do
          Survey.where(uuid: [nil, '']).find_each do |survey|
            survey.send(:generate_uuid)
            survey.save!
          end
        end

        change_column :surveys, :uuid, :string, null: false
        remove_index :surveys, :uuid
        add_index :surveys, :uuid, unique: true

        say_with_time "Migration EmbeddableUnit data to Survey records" do
          Survey.includes(:embeddable_units).find_each do |survey|
            if unit = survey.embeddable_units.first
              survey.update!(thank_you_markdown: unit.thank_you_markdown)
            end
          end
        end
      end

      dir.down do
        change_column :surveys, :uuid, :string, null: true
        remove_index :surveys, :uuid
        add_index :surveys, :uuid
      end
    end
  end
end
