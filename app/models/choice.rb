class Choice < ActiveRecord::Base
  belongs_to :question
  has_many :responses, class_name: "ChoiceResponse", dependent: :destroy

  validates :question, presence: true
  validates :title, presence: true, length: { maximum: 250 }
  validates :rotate, inclusion:{in:[true,false], allow_nil:true}

  def response_ratio
    question.choice_result_cache.response_ratio_for(self)
  end
end
