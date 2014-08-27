class Choice < ActiveRecord::Base
  has_many :responses, class_name: "ChoiceResponse", dependent: :destroy

  validates :question, presence: true
  validates :title, presence: true, length: { maximum: 250 }
  validates :rotate, inclusion:{in:[true,false], allow_nil:true}
end
