class Choice < ActiveRecord::Base
  belongs_to :question
  has_many :responses, class_name: "ChoiceResponse", dependent: :destroy

  validates :question, presence: true
  validates :title, presence: true, length: { maximum: 250 }
  validates :rotate, inclusion:{in:[true,false], allow_nil:true}

  def response_ratio
    question.responses.count == 0 ? 0 : responses.count / question.responses.count.to_f
  end
end
