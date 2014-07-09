class TwoCents::Categories < Grape::API
  resource :categories do
    desc "Return an array of categories", {
      notes: <<-END
        This API will return an ordered list of categories.

        #### Example response
            [
              {
                "id": 15,
                "name": "Business",
                "image": {
                  "url": "/uploads/category/image/15/portfolio1.png"
                },
                "icon": {
                  "url": "/uploads/category/icon/15/business-icon.png"
                }
              },
              {
                "id": 17,
                "name": "Sports",
                "image": {
                  "url": "/uploads/category/image/17/portfolio3.png"
                },
                "icon": {
                  "url": "/uploads/category/icon/17/sports-icon.png"
                }
              }
            ]
      END
    }
    params do
      requires :udid, type: String
      requires :remember_token, type: String
    end
    post "/", http_codes:[
      [400, "1000 - Invalid params"],
      [500, "1002 - Server error"],
      [401, "1003 - Forbidden: unregistered device, access denied"],
      [401, "1004 - Forbidden: invalid session, access denied"]
    ] do
      policy_scope(Category)
    end
  end
end
