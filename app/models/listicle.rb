class Listicle < ActiveRecord::Base
  belongs_to :user

  has_many :questions, -> { order(:id => :asc)}, class_name: 'ListicleQuestion', dependent: :destroy
  has_many :responses, through: :questions

  accepts_nested_attributes_for :questions, allow_destroy: true

  def get_intro
    intro.present? ? intro : default_intro
  end

  def default_intro
    'Untitled' + (created_at ?  "[#{created_at.strftime('%Y-%m-%d %H:%M')}]" : '')
  end

  def viral_distribution
    unique_referrers.count
  end

  def unique_referrers
    responses.where.not(original_referrer: '').pluck(:original_referrer).uniq
  end

  def deployment_count
    unique_referrers.map do |r|
      matches = r.match(/https?:\/\/([^\/]+)\/.*/)
      matches ? matches[1] : nil
    end.uniq.count
  end

  def response_count
    responses.count
  end

  def virality_rate
    unique_referrers.count.to_f / deployment_count unless deployment_count.to_i == 0
  end

  def complete_rate
    view_count > 0 ? response_count.to_f / view_count.to_f : 0
  end
end