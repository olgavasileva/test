class StudioResponse < Response
  belongs_to :scene

  validates :scene, presence: true

  accepts_nested_attributes_for :scene

  def description
    "A Scene"
  end
end