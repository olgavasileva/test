class Localization < ActiveRecord::Base
  belongs_to :language
  belongs_to :localizable, polymorphic: true

  validates :language, presence: true
  validates :localizable, presence: true
  validates :localizable_id, uniqueness: { scope: :localizable_type, message: "is already localized" }

  default localizable_type: "Studio"

  delegate :localize, to: :language
end
