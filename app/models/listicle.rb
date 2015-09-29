class Listicle < ActiveRecord::Base
  belongs_to :user

  has_many :questions, class_name: 'ListicleQuestion', dependent: :destroy

  accepts_nested_attributes_for :questions, allow_destroy: true

  def get_intro
    if intro.nil? || intro.empty?
      default_intro
    else
      intro
    end
  end

  def default_intro
    "Untitled [#{created_at.strftime('%Y-%m-%d %H:%M')}]"
  end
end