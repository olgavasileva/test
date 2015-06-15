class AddPublisherProUserType < ActiveRecord::Migration
  def up
    Role.find_or_create_by(name: 'publisher')
  end

  def down
    role = Role.find_by(name: 'publisher')
    role.destroy if role.present?
  end
end
