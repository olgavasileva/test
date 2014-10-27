class StudioQuestion < Question
  belongs_to :studio
  has_many :responses, class_name:"StudioResponse", foreign_key: :question_id

  validates :studio, presence: true
end