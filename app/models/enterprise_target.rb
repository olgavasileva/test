class EnterpriseTarget < Target
  has_and_belongs_to_many :segments

  default min_age: 14
  default max_age: nil
  default gender: nil

  validates :user, presence: true
  validates :min_age, numericality: { only_integer: true, greater_than: 13 }
  validates :max_age, numericality: { only_integer: true, greater_than_or_equal_to: :min_age, allow_nil: true }
  validates :gender, inclusion: { in: %w(male female both) }

  protected
    def apply! question
      question.update_attribute :kind, :targeted

      ActiveRecord::Base.transaction do
        # Intersection of age, gender and segments
        matching_ids = matching_age_and_gender_ids(question) & matching_segment_ids(question)
        target_respondents! question, Respondent.find(matching_ids)
      end
    end

  private
    def matching_age_and_gender_ids question
      # Age
      targets = if max_age.present?
        User.where(birthdate:(Date.current - max_age.years .. Date.current - min_age.years))
      else
        User.where("birthdate >= ?", Date.current - min_age.years)
      end

      # Gender
      targets = case gender
      when "male"
        targets.where(gender:"male")
      when "female"
        targets.where(gender:"female")
      when "both"
        targets
      end

      targets.pluck(:id)
    end

    def matching_segment_ids question
      # Segments (must match all)
      segment_ids = []
      segments.each do |segment|
        segment_ids += segment.matched_users.pluck(:id)
      end
      segment_ids.uniq
    end
end
