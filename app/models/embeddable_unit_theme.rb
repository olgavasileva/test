class EmbeddableUnitTheme < ActiveRecord::Base
  DEFAULT_THEME = 'statisfy'
  validates_presence_of :title, :color1, :color2, :main_color

  belongs_to :user, class_name: 'Respondent'
  has_many :surveys

  scope :default_themes, -> { where user: nil }
end
