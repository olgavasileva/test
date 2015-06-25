class EmbeddableUnitTheme < ActiveRecord::Base
  validates_presence_of :title, :color1, :color2, :main_color

  belongs_to :user, class_name: 'Respondent'

  scope :default_themes, -> { where user: nil }
end
