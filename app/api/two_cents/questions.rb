class TwoCents::Questions < Grape::API
  resource :questions do
    desc "Return an array of questions and related data for this user.", {
      notes: <<-END
        This API will return an ordered list of unanswered questions for this user.

        #### Example response
            [
                {
                    "question": {
                        "id": 1,
                        "type": "ChoiceQuestion",
                        "title": "Choice Title",
                        "description": "Choice Description",
                        "rotate": true,
                        "category": {
                            "id": 1,
                            "name": "Category 1"
                        },
                        "choices": [
                            {
                                "choice": {
                                    "id": 1,
                                    "rotate": true,
                                    "title": "Choice 1"
                                }
                            },
                            {
                                "choice": {
                                    "id": 2,
                                    "rotate": true,
                                    "title": "Choice 2"
                                }
                            },
                            {
                                "choice": {
                                    "id": 3,
                                    "rotate": false,
                                    "title": "Choice 3"
                                }
                            }
                        ]
                    }
                },
                {
                    "question": {
                        "id": 2,
                        "type": "MultipleChoiceQuestion",
                        "title": "Multiple Choice Title",
                        "description": "Multiple Choice Description",
                        "min_responses": 1,
                        "max_responses": 2,
                        "rotate": true,
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
                                    "title": "Multiple Choice 1"
                                }
                            },
                            {
                                "choice": {
                                    "id": 5,
                                    "muex": false,
                                    "rotate": true,
                                    "title": "Multiple Choice 2"
                                }
                            },
                            {
                                "choice": {
                                    "id": 6,
                                    "muex": true,
                                    "rotate": false,
                                    "title": "Multiple Choice 3"
                                }
                            }
                        ]
                    }
                }
            ]

      END
    }
    params do
      requires :auth_token, type:String, desc:'Obtain this from the instances API'
      optional :page, type: Integer, desc: "Page number, starting at 1 - all questions returned if not supplied"
      optional :per_page, type: Integer, default: 15, desc: "Number of questions per page"
    end
    post 'feed', rabl: "questions", http_codes:[
      [200, "402 - Invalid auth token"],
      [200, "400 - Invalid params"]
    ] do
      validate_user!

      page = declared_params[:page]
      per_page = page ? declared_params[:per_page] : nil
      questions = policy_scope(Question)

      @questions = questions.paginate(page:page, per_page:per_page)
    end
  end
end
