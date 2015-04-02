class FormatExistingTags < ActiveRecord::Migration
  def up
    say_with_time 'Ensuring existing tags are formatted correctly' do
      ActsAsTaggableOn::Tag.transaction do
        ActsAsTaggableOn::Tag.find_each do |tag|
          new_name = StatisfyTagParser.parse_tag(tag.name)
          unless new_name == tag.name
            if existing = ActsAsTaggableOn::Tag.find_by(name: new_name)
              query = ActsAsTaggableOn::Tagging.where(tag_id: tag.id)
              query.update_all(tag_id: existing.id)
              tag.destroy!
            else
              tag.update!(name: new_name)
            end
          end
        end
      end
    end

    say_with_time 'Updating all Tag#taggings_count' do
      ActiveRecord::Base.connection.execute <<-SQL.squish
        UPDATE tags
        SET taggings_count = (
          SELECT COUNT(tag_id)
          FROM taggings
          WHERE taggings.tag_id = tags.id
          GROUP BY tag_id
        )
      SQL
    end
  end

  def down
  end
end
