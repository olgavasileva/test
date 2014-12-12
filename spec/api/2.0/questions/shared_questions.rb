RSpec.shared_context :shared_questions do
  before(:all) do
    @question_image = FactoryGirl.create :question_image
    @choice_image = FactoryGirl.create :choice_image
    @order_choice_image = FactoryGirl.create :order_choice_image
  end

  let(:question_image) {@question_image}
  let(:choice_image) {@choice_image}
  let(:order_choice_image) {@order_choice_image}
  let(:category1) {FactoryGirl.create :category, name:"Category 1"}
  let(:category2) {FactoryGirl.create :category, name:"Category 2"}

  let(:text_choice_question) {FactoryGirl.create :text_choice_question, category:category1, title:"Text Choice Title", description:"Text Choice Description", background_image:question_image, rotate:true, created_at:Date.today - 4.days}
  let(:text_choice1) {FactoryGirl.create :text_choice, question:text_choice_question, title:"Text Choice 1", rotate:true}
  let(:text_choice2) {FactoryGirl.create :text_choice, question:text_choice_question, title:"Text Choice 2", rotate:true}
  let(:text_choice3) {FactoryGirl.create :text_choice, question:text_choice_question, title:"Text Choice 3", rotate:false}

  let(:multiple_choice_question) {FactoryGirl.create :multiple_choice_question, category:category2, title:"Multiple Choice Title", description:"Multiple Choice Description", rotate:true, min_responses:1, max_responses:2, created_at:Date.today - 3.days}
  let(:multiple_choice1) {FactoryGirl.create :multiple_choice, question:multiple_choice_question, title:"Multiple Choice 1", background_image:choice_image, rotate:true, muex:true}
  let(:multiple_choice2) {FactoryGirl.create :multiple_choice, question:multiple_choice_question, title:"Multiple Choice 2", background_image:choice_image, rotate:true, muex:false}
  let(:multiple_choice3) {FactoryGirl.create :multiple_choice, question:multiple_choice_question, title:"Multiple Choice 3", background_image:choice_image, rotate:false, muex:true}

  let(:image_choice_question) {FactoryGirl.create :image_choice_question, category:category2, title:"Image Choice Title", description:"Image Choice Description", rotate:false, created_at:Date.today - 2.days}
  let(:image_choice1) {FactoryGirl.create :image_choice, question:image_choice_question, title:"Image Choice 1", background_image:choice_image, rotate:false}
  let(:image_choice2) {FactoryGirl.create :image_choice, question:image_choice_question, title:"Image Choice 2", background_image:choice_image, rotate:false}

  let(:order_question) {FactoryGirl.create :order_question, category:category1, title:"Order Title", description:"Order Description", rotate:true, created_at:Date.today - 1.day}
  let(:order_choice1) {FactoryGirl.create :order_choice, question:order_question, title:"Order Choice 1", background_image:order_choice_image, rotate:true}
  let(:order_choice2) {FactoryGirl.create :order_choice, question:order_question, title:"Order Choice 2", background_image:order_choice_image, rotate:true}
  let(:order_choice3) {FactoryGirl.create :order_choice, question:order_question, title:"Order Choice 3", background_image:order_choice_image, rotate:false}

  let(:text_question) {FactoryGirl.create :text_question, category:category1, title:"Text Title", description:"Text Description", background_image:question_image, text_type:"freeform", min_characters:1, max_characters:100, created_at:Date.today}

  let(:q1) { text_choice_question }
  let(:q2) { multiple_choice_question }
  let(:q3) { image_choice_question }
  let(:q4) { order_question }
  let(:q5) { text_question }

  let(:all_questions) { [q1, q2, q3, q4, q5] }

  let(:setup_questions) {
    all_questions

    text_choice1; text_choice2; text_choice3
    multiple_choice1; multiple_choice2; multiple_choice3
    image_choice1; image_choice2
    order_choice1; order_choice2; order_choice3
  }
end
