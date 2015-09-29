class AddTimestampsToListicles < ActiveRecord::Migration
  def change
    add_timestamps :listicles
    Listicle.where(created_at: nil).find_each do |listicle|
      listicle.update_attributes(created_at: DateTime.now)
    end
  end
end
