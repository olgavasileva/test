class MultipleChoice < Choice
  belongs_to :question, class_name: "MultipleChoiceQuestion"
  has_many :choices_responses
  has_many :responses, through: :choices_responses

  validates :muex, inclusion:{in:[true,false]}
  validates :image, presence:true

protected
  after_initialize do
    if new_record?
      self.muex = false if muex.nil?
    end
  end
end
