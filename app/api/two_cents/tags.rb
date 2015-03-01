class TwoCents::Tags < Grape::API
  resource :tags do
    helpers do
      params :auth do
        requires :auth_token, {
          type: String,
          desc: "Obtain this from the instance's API."
        }
      end
    end

    # ----------------
    # GET /tags/search
    desc 'Search for existing tags'
    params do
      use :auth
      requires :search_string, type: String, desc: 'The tag to search for'
      optional :max_tags, {
        type: Integer,
        desc: 'The number of tags to return from the search query.',
        default: 20
      }
    end
    get :search, http_codes: [
      [200, '403 - Unauthorized']
    ] do
      validate_user!
      max = declared_params[:max_tags]
      tag = declared_params[:search_string]

      ActsAsTaggableOn::Tag.order(name: :asc)
        .where('name LIKE ?', "#{tag}%")
        .limit(max)
        .pluck(:name)
    end
  end
end
