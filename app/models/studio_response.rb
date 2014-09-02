class StudioResponse < Response
  belongs_to :scene

  validates :scene, presence: true
end