class TwoCents::Questions < Grape::API
  resource :questions do
    helpers do
      params :auth do
        requires :auth_token, type: String, desc: "Obtain this from the instance's API."
      end

      params :create do
        requires :category_id, type:Integer, desc:"Category for this question"
        requires :title, type:String, desc:"Title of question to display to the user"
        optional :description, type:String, desc:"Description - do we need this?"

        optional :invite_phone_numbers, type: Array, desc: "Phone numbers of people to invite to answer."
        optional :invite_email_addresses, type: Array, desc: "Email addresses of people to invite to answer."
        optional :anonymous, type: Boolean, desc: "Whether question is anonymous"

        requires :targets, type: Hash do
          optional :all, type: Boolean, desc: "Whether question is targeted at all users."
          optional :all_followers, type: Boolean, desc: "Whether question is targeted at all creator's followers."
          optional :all_groups, type: Boolean, desc: "Whether question is targeted at all creator's groups."
          optional :follower_ids, type: Array, default: [], desc: "IDs of users following creator targeted for question."
          optional :group_ids, type: Array, default: [], desc: "IDs of creator's groups targeted for question."
        end
      end
    end

    #
    # Create a TextChoiceQuestion
    #

    desc "Create a text choice question", {
      notes: <<-END
        A TextChoiceQuestion has an overview image and between 2 and 4 text choices of which a user can choose exactly one.

        ## Coming Soon
        requires :first_name

      END
    }
    params do
      use :auth
      use :create

      requires :image_url, type:String, desc:"URL of the overview image"
      requires :rotate, type:Boolean, desc:"True if choices should be presented in a random order", default:false

      requires :choices, type:Array do
        requires :title, type:String, desc:"Title of the choice to display to the user"
        requires :rotate, type:Boolean, desc:"This value is logically ANDed with question.rotate", default:true
      end
    end
    post 'text_choice_question', jbuilder: "question", http_codes:[
      [200, "400 - Invalid params"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"],
      [200, "2000 - At least 2 choice must be provided"],
      [200, "2001 - Not more than 4 choice may be provided"]
    ] do
      validate_user!

      fail!(2000, "At least 2 choice must be provided") if declared_params[:choices].count < 2
      fail!(2001, "Not more than 4 choice may be provided") if declared_params[:choices].count > 4

      category = Category.find declared_params[:category_id]

      background_image = if URI(declared_params[:image_url]).scheme.nil?
        QuestionImage.create!(image:open(declared_params[:image_url]))
      else
        QuestionImage.create!(remote_image_url:declared_params[:image_url])
      end

      question_params = {
        state: "active",
        user_id:current_user.id,
        category_id:category.id,
        title:declared_params[:title],
        description:declared_params[:description],
        rotate:declared_params[:rotate],
        background_image:background_image,
        anonymous: params[:anonymous]
      }

      @question = TextChoiceQuestion.new(question_params)

      declared_params[:choices].each do |choice_params|
        @question.choices.build title:choice_params[:title], rotate:choice_params[:rotate]
      end

      @question.save!

      # target = Target.new declared_params[:targets]
      # @question.apply_target! target
    end


    #
    # Create a MultipleChoiceQuestion
    #

    desc "Create a multiple image choice question", {
      notes: <<-END
        A MultipleChoiceQuestion has an image for each of 2, 3, or 4 image choices of which a user can choose more than one.
      END
    }
    params do
      use :auth
      use :create

      requires :rotate, type:Boolean, desc:"True if choices should be presented in a random order", default:false
      requires :min_responses, type:Integer, desc:"Minimum number of responses that must be selected"
      optional :max_responses, type:Integer, desc:"Maximum number of responses that can be selected.  Defaults to the number of choices."

      requires :choices, type:Array do
        requires :title, type:String, desc:"Title of the choice to display to the user"
        requires :image_url, type:String, desc:"URL of the choice image"
        requires :rotate, type:Boolean, desc:"This value is logically ANDed with question.rotate", default:true
        requires :muex, type:Boolean, desc:"If a muex choice is selected, no other choices are alloweed", default:false
      end
    end
    post 'multiple_choice_question', jbuilder: "question", http_codes:[
      [200, "400 - Invalid params"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"],
      [200, "2002 - The number of choices must be between 2 and 4"],
      [200, "2003 - min_responses must be less than or equal to the number of choices"],
      [200, "2004 - max_responses must be greater than or equal to min_responses"]
    ] do
      validate_user!

      num_choices = declared_params[:choices].count
      min_responses = declared_params[:min_responses]
      max_responses = declared_params[:max_responses].nil? ? num_choices : declared_params[:max_responses]

      fail!(2002, "The number of choices must be between 2 and 4") unless (2..4).include?(num_choices)
      fail!(2003, "min_responses must be less than or equal to the number of choices") unless min_responses <= num_choices
      fail!(2004, "max_responses must be greater than or equal to min_responses") unless max_responses >= min_responses

      category = Category.find declared_params[:category_id]

      question_params = {
        state: "active",
        user_id:current_user.id,
        category_id:category.id,
        title:declared_params[:title],
        description:declared_params[:description],
        rotate:declared_params[:rotate],
        min_responses:min_responses,
        max_responses:max_responses,
        target_all: params[:targets][:all],
        target_all_followers: params[:targets][:all_followers],
        target_all_groups: params[:targets][:all_groups],
        target_follower_ids: params[:targets][:follower_ids],
        target_group_ids: params[:targets][:group_ids],
        anonymous: params[:anonymous]
      }

      @question = MultipleChoiceQuestion.new(question_params)

      declared_params[:choices].each do |choice_params|
        background_image = if URI(choice_params[:image_url]).scheme.nil?
          ChoiceImage.create!(image:open(choice_params[:image_url]))
        else
          ChoiceImage.create!(remote_image_url:choice_params[:image_url])
        end

        @question.choices.build title:choice_params[:title], rotate:choice_params[:rotate], muex:choice_params[:muex], background_image:background_image
      end

      @question.save!

      # target = Target.new declared_params[:targets]
      # @question.apply_target! target
    end


    #
    # Create an ImageChoiceQuestion
    #

    desc "Create an image choice question", {
      notes: <<-END
        An ImageChoiceQuestion has an image for each of 2, 3, or 4 choices of which a user must choose exactly one.
      END
    }
    params do
      use :auth
      use :create

      requires :rotate, type:Boolean, desc:"True if choices should be presented in a random order", default:false

      requires :choices, type:Array do
        requires :title, type:String, desc:"Title of the choice to display to the user"
        requires :image_url, type:String, desc:"URL of the choice image"
        requires :rotate, type:Boolean, desc:"This value is logically ANDed with question.rotate", default:true
      end
    end
    post 'image_choice_question', jbuilder: "question", http_codes:[
      [200, "400 - Invalid params"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"],
      [200, "2002 - The number of choices must be between 2 and 4"]
    ] do
      validate_user!

      num_choices = declared_params[:choices].count
      fail!(2002, "The number of choices must be between 2 and 4") unless (2..4).include?(num_choices)

      category = Category.find declared_params[:category_id]

      question_params = {
        state: "active",
        user_id:current_user.id,
        category_id:category.id,
        title:declared_params[:title],
        description:declared_params[:description],
        rotate:declared_params[:rotate],
        target_all: params[:targets][:all],
        target_all_followers: params[:targets][:all_followers],
        target_all_groups: params[:targets][:all_groups],
        target_follower_ids: params[:targets][:follower_ids],
        target_group_ids: params[:targets][:group_ids],
        anonymous: params[:anonymous]
      }

      @question = ImageChoiceQuestion.new(question_params)

      declared_params[:choices].each do |choice_params|
        background_image = if URI(choice_params[:image_url]).scheme.nil?
          ChoiceImage.create!(image:open(choice_params[:image_url]))
        else
          ChoiceImage.create!(remote_image_url:choice_params[:image_url])
        end

        @question.choices.build title:choice_params[:title], rotate:choice_params[:rotate], background_image:background_image
      end

      @question.save!

      # target = Target.new declared_params[:targets]
      # @question.apply_target! target
    end



    #
    # Create an OrderQuestion
    #

    desc "Create an order question (prioritizer)", {
      notes: <<-END
        An OrderQuestion has an image for each of 2, 3, or 4 choices which a user must sort from best to worst.
      END
    }
    params do
      use :auth
      use :create

      requires :rotate, type:Boolean, desc:"True if choices should be presented in a random order", default:false

      requires :choices, type:Array do
        requires :title, type:String, desc:"Title of the choice to display to the user"
        requires :image_url, type:String, desc:"URL of the choice image"
        requires :rotate, type:Boolean, desc:"This value is logically ANDed with question.rotate", default:true
      end
    end
    post 'order_question', jbuilder: "question", http_codes:[
      [200, "400 - Invalid params"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"],
      [200, "2002 - The number of choices must be between 2 and 4"]
    ] do
      validate_user!

      num_choices = declared_params[:choices].count
      fail!(2002, "The number of choices must be between 2 and 4") unless (2..4).include?(num_choices)

      category = Category.find declared_params[:category_id]

      question_params = {
        state: "active",
        user_id:current_user.id,
        category_id:category.id,
        title:declared_params[:title],
        description:declared_params[:description],
        rotate:declared_params[:rotate],
        target_all: params[:targets][:all],
        target_all_followers: params[:targets][:all_followers],
        target_all_groups: params[:targets][:all_groups],
        target_follower_ids: params[:targets][:follower_ids],
        target_group_ids: params[:targets][:group_ids],
        anonymous: params[:anonymous]
      }

      @question = OrderQuestion.new(question_params)

      declared_params[:choices].each do |choice_params|
        background_image = if URI(choice_params[:image_url]).scheme.nil?
          ChoiceImage.create!(image:open(choice_params[:image_url]))
        else
          ChoiceImage.create!(remote_image_url:choice_params[:image_url])
        end

        @question.choices.build title:choice_params[:title], rotate:choice_params[:rotate], background_image:background_image
      end

      @question.save!

      # target = Target.new declared_params[:targets]
      # @question.apply_target! target
    end



    #
    # Create a TextQuestion
    #

    desc "Create a text question", {
      notes: <<-END
        A TextQuestion has an overview image and allows a user to type a text response.
      END
    }
    params do
      use :auth
      use :create

      requires :image_url, type:String, desc:"URL of the overview image"

      requires :text_type, type:String, values: TextQuestion::TEXT_TYPES, desc:"Type of text to collect: #{TextQuestion::TEXT_TYPES}"
      requires :min_characters, type:Integer
      requires :max_characters, type:Integer
    end
    post 'text_question', jbuilder: "question", http_codes:[
      [200, "400 - Invalid params"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"]
    ] do
      validate_user!

      category = Category.find declared_params[:category_id]

      background_image = if URI(declared_params[:image_url]).scheme.nil?
        QuestionImage.create!(image:open(declared_params[:image_url]))
      else
        QuestionImage.create!(remote_image_url:declared_params[:image_url])
      end

      question_params = {
        state: "active",
        user_id:current_user.id,
        category_id:category.id,
        title:declared_params[:title],
        background_image:background_image,
        description:declared_params[:description],
        text_type:declared_params[:text_type],
        min_characters:declared_params[:min_characters],
        max_characters:declared_params[:max_characters],
        target_all: params[:targets][:all],
        target_all_followers: params[:targets][:all_followers],
        target_all_groups: params[:targets][:all_groups],
        target_follower_ids: params[:targets][:follower_ids],
        target_group_ids: params[:targets][:group_ids],
        anonymous: params[:anonymous]
      }

      @question = TextQuestion.new(question_params)

      @question.save!

      # target = Target.new declared_params[:targets]
      # @question.apply_target! target
    end


    #
    # Return the Question Feed
    #

    desc "Return an array of questions and related data for this user.", {
      notes: <<-END
        This API will return an ordered list of unanswered questions for this user.

        #### Example response
            [
                {
                    "question": {
                        "type": "TextChoiceQuestion",
                        "id": 1,
                        "uuid": "SOMEUUID",
                        "title": "Text Choice Title",
                        "description": "Text Choice Description",
                        "image_url": "http://crashmob.com/Example.jpg",
                        "rotate": true,
                        "response_count": 8,
                        "comment_count": 5,
                        "category": {
                            "id": 1,
                            "name": "Category 1"
                        },
                        "choices": [
                            {
                                "choice": {
                                    "id": 1,
                                    "rotate": true,
                                    "title": "Text Choice 1"
                                }
                            },
                            {
                                "choice": {
                                    "id": 2,
                                    "rotate": true,
                                    "title": "Text Choice 2"
                                }
                            },
                            {
                                "choice": {
                                    "id": 3,
                                    "rotate": false,
                                    "title": "Text Choice 3"
                                }
                            }
                        ]
                    }
                },
                {
                    "question": {
                        "type": "MultipleChoiceQuestion",
                        "id": 2,
                        "uuid": "SOMEUUID",
                        "title": "Multiple Choice Title",
                        "description": "Multiple Choice Description",
                        "min_responses": 1,
                        "max_responses": 2,
                        "rotate": true,
                        "response_count": 8,
                        "comment_count": 5,
                        "category": {
                            "id": 2,
                            "name": "Category 2"
                        },
                        "choices": [
                            {
                                "choice": {
                                    "id": 4,
                                    "muex": true,
                                    "rotate": true,
                                    "image_url": "http://crashmob.com/Example.jpg",
                                    "title": "Multiple Choice 1"
                                }
                            },
                            {
                                "choice": {
                                    "id": 5,
                                    "muex": false,
                                    "rotate": true,
                                    "image_url": "http://crashmob.com/Example.jpg",
                                    "title": "Multiple Choice 2"
                                }
                            },
                            {
                                "choice": {
                                    "id": 6,
                                    "muex": true,
                                    "rotate": false,
                                    "image_url": "http://crashmob.com/Example.jpg",
                                    "title": "Multiple Choice 3"
                                }
                            }
                        ]
                    }
                },
                {
                    "question": {
                        "type": "ImageChoiceQuestion",
                        "id": 3,
                        "uuid": "SOMEUUID",
                        "title": "Image Choice Title",
                        "description": "Image Choice Description",
                        "rotate": false,
                        "response_count": 8,
                        "comment_count": 5,
                        "category": {
                            "id": 2,
                            "name": "Category 2"
                        },
                        "choices": [
                            {
                                "choice": {
                                    "id": 7,
                                    "image_url": "http://crashmob.com/Example.jpg",
                                    "rotate": false,
                                    "title": "Image Choice 1"
                                }
                            },
                            {
                                "choice": {
                                    "id": 8,
                                    "image_url": "http://crashmob.com/Example.jpg",
                                    "rotate": false,
                                    "title": "Image Choice 2"
                                }
                            }
                        ]
                    }
                },
                {
                    "question": {
                        "type": "OrderQuestion",
                        "id": 4,
                        "uuid": "SOMEUUID",
                        "title": "Order Title",
                        "description": "Order Description",
                        "rotate": true,
                        "response_count": 0,
                        "comment_count": 0,
                        "category": {
                            "id": 1,
                            "name": "Category 1"
                        },
                        "choices": [
                            {
                                "choice": {
                                    "id": 9,
                                    "image_url": "http://crashmob.com/Example.jpg",
                                    "rotate": true,
                                    "title": "Order Choice 1"
                                }
                            },
                            {
                                "choice": {
                                    "id": 10,
                                    "image_url": "http://crashmob.com/Example.jpg",
                                    "rotate": true,
                                    "title": "Order Choice 2"
                                }
                            },
                            {
                                "choice": {
                                    "id": 11,
                                    "image_url": "http://crashmob.com/Example.jpg",
                                    "rotate": false,
                                    "title": "Order Choice 3"
                                }
                            }
                        ]
                    }
                },
                {
                    "question": {
                        "type": "TextQuestion"
                        "id": 5,
                        "uuid": "SOMEUUID",
                        "title": "Text Title",
                        "description": "Text Description",
                        "image_url": "http://crashmob.com/Example.jpg",
                        "text_type": "freeform" | "email" | "phone",
                        "min_characters": 1,
                        "max_characters": 100,
                        "response_count": 0,
                        "comment_count": 0,
                        "category": {
                            "id": 1,
                            "name": "Category 1"
                        },
                    }
                }
            ]
      END
    }
    params do
      use :auth

      optional :page, type: Integer, desc: "Page number, starting at 1 - all questions returned if not supplied"
      optional :per_page, type: Integer, default: 15, desc: "Number of questions per page"
    end
    post 'feed', jbuilder: "questions", http_codes:[
      [200, "400 - Invalid params"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"]
    ] do
      validate_user!

      page = declared_params[:page]
      per_page = page ? declared_params[:per_page] : 15

      @questions = policy_scope(Question).paginate(page: page, per_page:per_page)

      if @questions.count < per_page * page.to_i + per_page + 1
        current_user.feed_more_questions per_page + 1
        @questions = policy_scope(Question).paginate(page: page, per_page:per_page)
      end

      @questions.each{|q| q.viewed!}
    end


    #
    # Return asked questions.
    #

    desc "Return list of questions asked by a user."
    params do
      use :auth

      optional :user_id, type: Integer, desc: "User ID. Defaults to logged in user's ID."
      optional :page, type: Integer, desc: "Page number, minimum 1. If left blank, responds with all questions."
      optional :per_page, type: Integer, default: 15, desc: "Number of questions per page."
    end
    post 'asked' do
      user_id = params[:user_id]
      user = user_id.present? ? User.find(user_id) : current_user

      questions = user.questions

      if params[:page]
        questions = questions.paginate(page: params[:page],
                                       per_page: params[:per_page])
      end

      questions.map do |q|
        {
          id: q.id,
          title: q.title
        }
      end
    end


    #
    # Return answered questions.
    #

    desc "Return list of questions answered by a user."
    params do
      use :auth

      optional :user_id, type: Integer, desc: "User ID. Defaults to logged in user's ID."
      optional :page, type: Integer, desc: "Page number, minimum 1. If left blank, responds with all questions."
      optional :per_page, type: Integer, default: 15, desc: "Number of questions per page."
    end
    post 'answered' do
      user_id = params[:user_id]
      user = user_id.present? ? User.find(user_id) : current_user

      questions = user.answered_questions

      if params[:page]
        questions = questions.paginate(page: params[:page],
                                       per_page: params[:per_page])
      end

      questions.map do |question|
        {
          id: question.id,
          title: question.title
        }
      end
    end


    #
    # Return a TextQuestion's responses.
    #

    desc "Return list of a TextQuestion's responses."
    params do
      use :auth

      requires :question_id, type: Integer, desc: "ID of TextQuestion."
      optional :page, type: Integer, desc: "Page number, minimum 1. If left blank, responds with all answers."
      optional :per_page, type: Integer, default: 15, desc: "Number of answers per page."
    end
    get 'responses' do
      validate_user!

      question = TextQuestion.find(params[:question_id])

      unless question.public? || current_user.questions.include?(question)
        fail! 400, "Question isn't public and doesn't belong to user."
      end

      responses = question.responses

      if params[:page]
        responses = responses.paginate(page: params[:page],
                                       per_page: params[:per_page])
      end

      responses.map do |r|
        {
          id: r.id,
          user_id: r.user.id,
          text: r.text
        }
      end
    end

    #
    # Submit a user's response
    #

    desc "Submit responses to the survey questions", {
      notes: <<-END
        When the user answers a question, use this API to submit the response.
        The server will return summary information about the question.

        #### Example JSON to supply in the **response** parameter
              // text question response
              { "text":"What they typed" }

              // text or image choice question response
              { "choice_id":234 }

              // multiple choice question response
              { "choice_ids":[123,234,345,456] }

              // prioritizer response (id's in order of preference)
              { "choice_ids":[123,234,345,456] }

        #### Example response
            { "summary":
              {
                response_count:700,
                view_count:1000,
                comment_count:500,
                share_count:150,
                skip_count:1000,
                published_at: "June 5, 2014",
                sponsor: "Some Person" or nil,
                creator_id: <User ID of creator>,
                creator_name: "Creator's Name",
                anonymous: true
              }
            }
      END
    }
    params do
      use :auth

      requires :question_id, type: Integer, desc: 'Question this is a response to'
      optional :comment, type: String, desc: 'Some comment about the question'
      optional :anonymous, type: Boolean, default:false, desc: "True if the user want's to remain anonymous"

      optional :text, type: String, desc: 'What the user typed when responding to a TextQuestion'
      optional :choice_id, type: Integer, desc: 'The single choice selected in a TextChoiceQuestion or ImageChoiceQuestion'
      optional :choice_ids, type: Array, desc: 'The choices selected in a MultipleChoiceQuestion or ordered by an OrderQuestion'
      mutually_exclusive :text, :choice_id, :choice_ids

      optional :comment_parent_id, type: Integer, desc: "Comment parent response's ID."

      optional :filter_group, type: Symbol, values:[:all, :friends, :followers, :following, :me], desc: ":all, :friends, :followers, :following, :me"
      optional :filter_gender, type: Symbol, values:[:all, :male, :female], desc: ":all, :male, :female"
      optional :filter_geography, type: Symbol, values:[:all, :near_me], desc: ":all, :near_me"
      optional :filter_age_group, type: Symbol, values:[:all, :under_18, :from_19_to_34, :from_35_to_50, :over_50], desc: ":all, :under_18, :from_19_to_34, :from_35_to_50, :over_50"
    end
    post 'response', jbuilder: "summary", http_codes:[
      [200, "400 - Invalid params"],
      [200, "401 - Couldn't find Question"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"]
    ] do
      validate_user!

      @question = Question.find declared_params[:question_id]

      resp_param_keys =
        %w[comment anonymous text choice_id choice_ids comment_parent_id]
      resp_params = params.to_h.slice(*resp_param_keys)
      resp_params['user_id'] = current_user.id

      @question.responses.create!(resp_params)

      @anonymous = declared_params[:anonymous]
    end


    #
    # Obtain summary information about a question
    #

    desc "Obtain summary information about a question", {
      notes: <<-END
        Return summary information about the question.

        #### Example response
            { "summary":
              {
                response_count:700,
                view_count:1000,
                comment_count:500,
                share_count:150,
                skip_count:1000,
                published_at: "June 5, 2014",
                sponsor: "Some Person" or nil,
                creator_id: <User ID of creator>,
                creator_name: "Creator's Name",
                anonymous: true
              }
            }
      END
    }
    params do
      use :auth

      requires :question_id, type: Integer, desc: 'Question this is a response to'

      optional :filter_group, type: Symbol, values:[:all, :friends, :followers, :following, :me], desc: ":all, :friends, :followers, :following, :me"
      optional :filter_gender, type: Symbol, values:[:all, :male, :female], desc: ":all, :male, :female"
      optional :filter_geography, type: Symbol, values:[:all, :near_me], desc: ":all, :near_me"
      optional :filter_age_group, type: Symbol, values:[:all, :under_18, :from_19_to_34, :from_35_to_50, :over_50], desc: ":all, :under_18, :from_19_to_34, :from_35_to_50, :over_50"
    end
    post 'summary', jbuilder: "summary", http_codes:[
      [200, "400 - Invalid params"],
      [200, "401 - Couldn't find Question"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"]
    ] do
      validate_user!

      @question = Question.find declared_params[:question_id]
      @anonymous = @question.responses.where(user:current_user).last.try(:anonymous)
    end


    desc "Return a question's information.", {
      notes: <<-END
        Return a question's information.

        #### Example response
        {
            "category": {
                "id": 1,
                "name": "Name3"
            },
            "comment_count": 0,
            "creator_id": 2,
            "creator_name": "Name2",
            "description": null,
            "id": 1,
            "response_count": 0,
            "summary": {
                "anonymous": null,
                "choices": [],
                "comment_count": 0,
                "creator_id": 2,
                "creator_name": "Name2",
                "published_at": 1412038351,
                "response_count": 0,
                "share_count": 0,
                "skip_count": 0,
                "sponsor": null,
                "view_count": null
            },
            "title": "Name4",
            "type": null,
            "user_answered": false,
            "uuid": "Qfbad26b02a6901324a6e3c075421a6ee"
        }
      END
    }

    params do
      use :auth

      requires :question_id, type: Integer, desc: "ID of question."
      optional :user_id, type: Integer, desc: "ID of user for question answer data, defaults to current user's ID."
    end
    get 'question', jbuilder: "question_info" do
      validate_user!

      @question = Question.find(params[:question_id])
      user = User.find(params.fetch(:user_id, current_user.id))
      @user_answered = user.answered_questions.include? @question
    end


    #
    # Flag a question as inappropriate
    #

    desc "Flag inappropriate question"
    params do
      use :auth

      requires :question_id, type: Integer, desc: 'Question this is a response to'
      requires :reason, type: String, desc: "Reason that question is inappropriate"
    end
    post 'inappropriate', http_codes:[
      [200, "400 - Invalid params"],
      [200, "401 - Couldn't find Question"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"]
    ] do
      validate_user!

      QuestionReport.create!(
        user: current_user,
        question: Question.find(params[:question_id]),
        reason: params[:reason]
      )

      {}
    end


    #
    # Like a question
    #

    desc "Like a question"
    params do
      use :auth

      requires :question_id, type: Integer, desc: 'Question this is a response to'
    end
    post 'like', http_codes:[
      [200, "400 - Invalid params"],
      [200, "401 - Couldn't find Question"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"]
    ] do
      validate_user!
      @question = Question.find declared_params[:question_id]

      {}
    end


    #
    # Follow a question
    #

    desc "Follow a question"
    params do
      use :auth

      requires :question_id, type: Integer, desc: 'Question this is a response to'
    end
    post 'follow', http_codes:[
      [200, "400 - Invalid params"],
      [200, "401 - Couldn't find Question"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"]
    ] do
      validate_user!
      @question = Question.find declared_params[:question_id]

      {}
    end


    #
    # Start to answer a question
    #

    desc "Start to answer a question"
    params do
      use :auth

      requires :question_id, type: Integer, desc: 'Question this is a response to'
    end
    post 'follow', http_codes:[
      [200, "400 - Invalid params"],
      [200, "401 - Couldn't find Question"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"]
    ] do
      validate_user!
      @question = Question.find declared_params[:question_id]
      fail! 401, "Coulnd't find Question" unless @question

      @question.start!

      {}
    end


    #
    # Increment a question's view count.
    #
    desc "Increment a question's view count"
    params do
      use :auth

      requires :question_id, type: Integer, desc: 'Question this is a response to'
    end
    post 'view' do
      validate_user!

      Question.find(params[:question_id]).increment! :view_count

      {}
    end

    desc "Skip a question."
    params do
      use :auth

      requires :question_id, type: Integer, desc: "ID of question."
    end
    put 'skip' do
      validate_user!

      question = Question.find(params[:question_id])

      SkippedItem
        .where(user_id: current_user.id, question_id: question.id)
        .first_or_create!

      {}
    end

    desc "Start a question."
    params do
      use :auth

      requires :question_id, type: Integer, desc: "ID of question."
    end
    post 'start' do
      validate_user!

      Question.find(params[:question_id]).increment! :start_count

      {}
    end
  end
end
