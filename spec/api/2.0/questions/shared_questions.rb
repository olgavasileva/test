RSpec.shared_context :shared_questions do
  before(:all) do
    @question_user = FactoryGirl.create(:user)

    @question_image = FactoryGirl.create(:question_image)
    @choice_image = FactoryGirl.create(:choice_image)
    @order_choice_image = FactoryGirl.create(:order_choice_image)

    @category1 = FactoryGirl.create(:category, name: "Category 1")
    @category2 = FactoryGirl.create(:category, name: "Category 2")

    @text_choice_question = FactoryGirl.create(:text_choice_question, {
      user: @question_user,
      category: @category1,
      title: "Text Choice Title",
      description: "Text Choice Description",
      background_image: @question_image,
      rotate: true,
      created_at: Date.today - 4.days
    })

    @text_choice1 = FactoryGirl.create(:text_choice, title: 'Text Choice 1', question: @text_choice_question, rotate: true)
    @text_choice2 = FactoryGirl.create(:text_choice, title: 'Text Choice 2', question: @text_choice_question, rotate: true)
    @text_choice3 = FactoryGirl.create(:text_choice, title: 'Text Choice 3', question: @text_choice_question, rotate: false)

    @multiple_choice_question = FactoryGirl.create(:multiple_choice_question, {
      user: @question_user,
      category: @category2,
      title: "Multiple Choice Title",
      description: "Multiple Choice Description",
      rotate: true,
      min_responses: 1,
      max_responses: 2,
      created_at: Date.today - 3.days
    })

    @multiple_choice1 = FactoryGirl.create(:multiple_choice, title: 'Multiple Choice 1', question: @multiple_choice_question, background_image: @choice_image, rotate: true, muex: true)
    @multiple_choice2 = FactoryGirl.create(:multiple_choice, title: 'Multiple Choice 2', question: @multiple_choice_question, background_image: @choice_image, rotate: true, muex: false)
    @multiple_choice3 = FactoryGirl.create(:multiple_choice, title: 'Multiple Choice 3', question: @multiple_choice_question, background_image: @choice_image, rotate: false, muex: true)

    @image_choice_question = FactoryGirl.create(:image_choice_question, {
      user: @question_user,
      category: @category2,
      title: "Image Choice Title",
      description: "Image Choice Description",
      rotate: false,
      created_at: Date.today - 2.days
    })

    @image_choice1 = FactoryGirl.create(:image_choice, title: 'Image Choice 1', question: @image_choice_question, background_image: @choice_image, rotate: false)
    @image_choice2 = FactoryGirl.create(:image_choice, title: 'Image Choice 2', question: @image_choice_question, background_image: @choice_image, rotate: false)

    @order_question = FactoryGirl.create(:order_question, {
      user: @question_user,
      category: @category1,
      title: "Order Title",
      description: "Order Description",
      rotate: true,
      created_at: Date.today - 1.day
    })

    @order_choice1 = FactoryGirl.create(:order_choice, title: 'Order Choice 1', question: @order_question, background_image: @order_choice_image, rotate: true)
    @order_choice2 = FactoryGirl.create(:order_choice, title: 'Order Choice 2', question: @order_question, background_image: @order_choice_image, rotate: true)
    @order_choice3 = FactoryGirl.create(:order_choice, title: 'Order Choice 3', question: @order_question, background_image: @order_choice_image, rotate: false)

    @text_question = FactoryGirl.create(:text_question, {
      user: @question_user,
      category: @category1,
      title: "Text Title",
      description: "Text Description",
      background_image: @question_image,
      text_type: "freeform",
      min_characters: 1,
      max_characters: 100,
      created_at: Date.today
    })
  end

  let(:question_image) { @question_image }
  let(:choice_image) { @choice_image }
  let(:order_choice_image) { @order_choice_image }

  let(:category1) { @category1 }
  let(:category2) { @category2 }

  let(:text_choice_question) { @text_choice_question }
  let(:text_choice1) { @text_choice1 }
  let(:text_choice2) { @text_choice2 }
  let(:text_choice3) { @text_choice3 }

  let(:multiple_choice_question) { @multiple_choice_question }
  let(:multiple_choice1) { @multiple_choice1 }
  let(:multiple_choice2) { @multiple_choice2 }
  let(:multiple_choice3) { @multiple_choice3 }

  let(:image_choice_question) { @image_choice_question }
  let(:image_choice1) { @image_choice1 }
  let(:image_choice2) { @image_choice2 }

  let(:order_question) { @order_question }
  let(:order_choice1) { @order_choice1 }
  let(:order_choice2) { @order_choice2 }
  let(:order_choice3) { @order_choice3 }

  let(:text_question) { @text_question }

  let(:q1) { text_choice_question }
  let(:q2) { multiple_choice_question }
  let(:q3) { image_choice_question }
  let(:q4) { order_question }
  let(:q5) { text_question }

  let(:all_questions) { [q1, q2, q3, q4, q5] }

  let(:setup_questions) { }
end
