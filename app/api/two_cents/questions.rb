class TwoCents::Questions < Grape::API
  resource :questions do
    desc "Return an array of questions and related data for this user.", {
      notes: <<-END
        This API will return an ordered list of unanswered questions for this user.

        #### Example response
            [
                {
                    "question": {
                        "description": "Text Choice Description",
                        "id": 1,
                        "image_url": "http://crashmob.com/Example.jpg",
                        "rotate": true,
                        "title": "Text Choice Title",
                        "type": "TextChoiceQuestion",
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
                        "description": "Multiple Choice Description",
                        "id": 2,
                        "max_responses": 2,
                        "min_responses": 1,
                        "rotate": true,
                        "title": "Multiple Choice Title",
                        "type": "MultipleChoiceQuestion",
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
                },
                {
                    "question": {
                        "description": "Image Choice Description",
                        "id": 3,
                        "rotate": false,
                        "title": "Image Choice Title",
                        "type": "ImageChoiceQuestion",
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
