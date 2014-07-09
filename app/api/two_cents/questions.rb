class TwoCents::Questions < Grape::API
  resource :questions do
    desc "Return an array of questions and related data for this user.", {
      notes: <<-END
        This API will return an ordered list of unanswered questions for this user.

        #### Example response
            [
              {
                "id": 63,
                "title": "How many years do you think you will live?",
                "category": {
                  "id": 16,
                  "name": "Values",
                  "image": {
                    "url": "/uploads/category/image/16/portfolio2.png"
                  },
                  "icon": {
                    "url": "/uploads/category/icon/16/values-icon.png"
                  }
                },
                "choices": [
                  {
                    "id": 244,
                    "question_id": 63,
                    "title": "A few more",
                    "position": null,
                    "rotate": null,
                    "muex": null,
                    "image": {
                      "url": null,
                      "thumb": {
                        "url": null
                      }
                    }
                  }
                ],
                "user": {
                  "id": 5,
                  "username": "crashmob",
                  "name": "Question Master"
                }
              }
            ]
      END
    }
    params do
      requires :udid, type: String
      requires :remember_token, type: String
      optional :page, type: Integer, desc: "Page number, starting at 1 - all questions returned if not supplied"
      optional :per_page, type: Integer, default: 15, desc: "Number of questions per page"
    end
    post 'feed', http_codes:[
      [400, "1000 - Invalid params"],
      [500, "1002 - Server error"],
      [401, "1003 - Forbidden: unregistered device, access denied"],
      [401, "1004 - Forbidden: invalid session, access denied"]
    ] do
      page = declared_params[:page]
      per_page = page ? declared_params[:per_page] : nil
      questions = policy_scope(Question)
      questions.paginate(page:page, per_page:per_page)
    end
  end
end
