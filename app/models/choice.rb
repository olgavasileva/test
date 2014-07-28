class Choice < ActiveRecord::Base
	belongs_to :question
	has_many :responses, class_name: "ChoiceResponse", dependent: :destroy

	validates :question, presence: true
  validates :title, presence: true
  validates :rotate, inclusion:{in:[true,false], allow_nil:true}

  mount_uploader :image, QuestionImageUploader

  def device_image_url
    image.device.url
  end
end
