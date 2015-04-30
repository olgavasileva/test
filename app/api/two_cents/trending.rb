module TwoCents
  class Trending < Grape::API
    helpers do
      params :auth do
        requires :auth_token, {
          type: String,
          desc: "Obtain this from the instance's API."
        }
      end

      params :pagination do
        optional :page, type: Integer, default: 1
        optional :per_page, type: Integer, default: 20
      end
    end

    resource :trending do

      desc 'Trending tags', {
        notes: <<-NOTES
          This endpoint returns the tags for questions from the trending list.

          #### Notes:

          These results are returned in order of most used to least used during a time period.

          The numbers of questions asked for each user during that time period **ARE NOT** returned in the response.

          #### Example Response:

          See **profile.json** for an example **User** object.

          ```json
          {
            "tags": [
              {
                "tag": "lol",
                "count": 121,
              },
              {
                "tag": "food",
                "count": 40
              },
            ]
          }
          ```
        NOTES
      }
      params do
        use :auth
        use :pagination
        optional :days, type: Integer, default: 14, desc: 'The number of days back in time to consider'
      end
      get '/tags' do
        validate_user!

        days = params[:days].to_i
        days = 14 unless days > 0

        offset = params[:page].to_i - 1
        offset = 0 if offset < 0

        tags = ActsAsTaggableOn::Tagging.joins(:tag)
          .select('tags.name as name, COUNT(taggings.id) as tags_count')
          .group(:tag_id)
          .where('taggings.created_at >= ?', days.days.ago.beginning_of_day)
          .order('tags_count DESC ')
          .limit(declared_params[:per_page])
          .offset(offset)

        tags_json = tags.map do |tag|
          {tag: tag.name, count: tag.tags_count}
        end

        {tags: tags_json}
      end

      desc 'Trending users', {
        notes: <<-NOTES
          This endpoint returns trending users sorted by the most questions asked over a certain period of time.

          #### Notes:

          These results are returned in order of most asked to least asked during the time period.

          The numbers of questions asked for each user during that time period **ARE NOT** returned in the response.

          #### Example Response:

          See **profile.json** for an example **User** object.

          ```json
          {
            "users": [
              { /* See User Profile */ },
              { /* See User Profile */ }
            ]
          }
          ```
        NOTES
      }
      params do
        use :auth
        use :pagination
        optional :days, type: Integer, default: 14, desc: 'The number of days back in time to consider'
      end
      get '/users', jbuilder: 'users' do
        validate_user!

        days = params[:days].to_i
        days = 14 unless days > 0

        @users = Respondent.joins(:questions)
          .group('questions.user_id')
          .where('questions.created_at >= ?', days.days.ago.beginning_of_day)
          .order('COUNT(questions.id) desc')
          .uniq
          .page(params[:page])
          .per_page(params[:per_page])
      end
    end
  end
end
