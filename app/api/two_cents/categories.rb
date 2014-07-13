class TwoCents::Categories < Grape::API
  resource :categories do
    desc "Return an array of categories", {
      notes: <<-END
        This API will return an ordered list of categories.

        #### Example response
            [
                {
                    "category": {
                        "id": 1,
                        "name": "Category 1"
                    }
                },
                {
                    "category": {
                        "id": 2,
                        "name": "Category 2"
                    }
                }
            ]
      END
    }
    params do
      requires :auth_token, type:String, desc:'Obtain this from the instances API'
    end
    post "/", rabl: "categories", http_codes:[
      [200, "402 - Invalid auth token"],
      [200, "400 - Invalid params"]
    ] do
      validate_user!

      @categories = policy_scope(Category)
    end
  end
end
