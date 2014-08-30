class StudioResponse < StudioResponse
  belongs_to :scene

  validates :scene, presence: true
end