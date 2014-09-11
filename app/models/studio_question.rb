class StudioQuestion < Question
  belongs_to :studio

  validates :studio, presence: true
end