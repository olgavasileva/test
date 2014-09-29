class ItemProperty < ActiveRecord::Base
  belongs_to :item, polymorphic: true
  validates_presence_of :key, :value, :item_id, :item_type

  def to_builder
    Jbuilder.new do |prop|
      prop.extract self, :key, :value
    end
  end
end
