class Language < ActiveRecord::Base
  has_many :translations, dependent: :destroy

  accepts_nested_attributes_for :translations, allow_destroy: true

  def localize key
    translations.find_by(key:key).try(:value) || key
  end
end
