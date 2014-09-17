class StudioResponse < Response
  belongs_to :scene

  validates :scene, presence: true

  def description
    "A Scene"
  end
end