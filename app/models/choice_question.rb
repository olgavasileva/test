class ChoiceQuestion < Question
  has_many :responses, class_name:"ChoiceResponse", foreign_key: :question_id

  default rotate: true

  validates :rotate, inclusion: {in:[true,false]}

  def response_ratios
    ratios = {}

    if responses.any?
      choices.each do |choice|
        ratios[choice] = choice.responses.count / responses.count.to_f
      end
    else
      choices.each { |c| ratios[c] = 0 }
    end

    ratios
  end
end
