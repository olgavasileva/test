class EmbeddableUnit < ActiveRecord::Base
  belongs_to :survey

  default :uuid do |eu|
    "EU"+UUID.new.generate.gsub(/-/, '')
  end

  default width: 550
  default height: 550

  validates :uuid, presence: true
  validates :width, presence: true, numericality: {greater_than: 0}
  validates :height, presence: true, numericality: {greater_than: 0}
end
