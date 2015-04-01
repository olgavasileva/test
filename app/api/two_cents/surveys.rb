module TwoCents
  class Surveys < Grape::API
    helpers do
      params :auth do
        requires :auth_token, type: String, desc: 'Auth token for the user'
      end

      params :survey_id do
        requires :survey_id, type: String, desc: "The Survey id."
      end

      params :survey do |opts|
        type = opts[:type] || :optional
        send(type, :name, type: String, desc: 'Survey name')
        send(type, :thank_you_markdown, type: String, desc: 'Thank you message in Markdown format')
      end

      params :unit_uuid do |opts|
        requires :uuid, type: String, desc: 'The EmbeddableUnit uuid.'
      end

      params :question_id do |opts|
        requires :question_id, type: Integer, desc: 'The question id.'
      end

      def survey_params
        declared_params.slice(:name, :thank_you_markdown)
      end

      def survey_scope
        current_user.surveys
      end

      def load_survey!
        survey_scope.find(params[:survey_id])
      end

      def embeddable_unit_scope
        current_user.embeddable_units
      end

      def load_embeddable_unit!
        embeddable_unit_scope.find_by!(uuid: params[:uuid])
      end

      def question_atts
        {question_id: declared_params[:question_id]}
      end
    end

    resource :surveys do

      # ----------------------------------------------------------------------
      # Surveys: Create
      #
      desc 'Creates an survey', {
        notes: "See `GET surveys/:survey_id` for example response."
      }
      params do
        use :auth
        use :survey, type: :requires
      end
      post '/', jbuilder: 'survey', http_codes: [] do
        validate_user!
        @survey = survey_scope.create!(survey_params)
      end

      route_param :survey_id do

        # ----------------------------------------------------------------------
        # Surveys: Retreive
        #
        desc 'Returns a survey', {
          notes: <<-NOTES
            ### Example Response

            ```
            {
              "survey": {
                "id": 1,
                "name": "Soda Pop Questionaire",
                "thank_you_markdown": '**Thank You**',
                "thank_you_html": '<p><strong>Thank You</strong></p>',
                "user_id": 1,
                "questions": [], // Array of questions,
              }
            }
            ```
          NOTES
        }
        params do
          use :auth
          use :survey_id
        end
        get '/', jbuilder: 'survey' do
          validate_user!
          @survey = load_survey!
        end

        # ----------------------------------------------------------------------
        # Surveys: Update
        #
        desc 'Updates a survey', {
          notes: "See `GET surveys/:survey_id` for example response."
        }
        params do
          use :auth
          use :survey_id
          use :survey, type: :optional
        end
        put '/', jbuilder: 'survey' do
          validate_user!
          @survey = load_survey!
          @survey.update!(survey_params)
        end

        # ----------------------------------------------------------------------
        # Surveys: Delete
        #
        desc 'Deletes a survey', {
          notes: 'Returns a `204 No Content` status only on success.'
        }
        params do
          use :auth
          use :survey_id
        end
        delete '/' do
          validate_user!
          survey = load_survey!
          survey.destroy!
          status 204
        end

        # ----------------------------------------------------------------------
        # Survey -> Questions
        #
        resource :questions do
          route_param :question_id do

            # ------------------------------------------------------------------
            # Questions: Add
            #
            desc 'Adds a question to the survey.', {
              notes: "Returns a `204 No Content` on success"
            }
            params do
              use :auth
              use :survey_id
              use :question_id
            end
            post '/' do
              validate_user!
              survey = load_survey!
              # Load the question through the user to ensure its the same user
              # as the survey.... only reason we're making the query here
              question = current_user.questions.find(params[:question_id])
              query = survey.questions_surveys.where(question: question)
              query.first_or_create!
              status 204
            end

            # ------------------------------------------------------------------
            # Questions: Remove
            #
            desc 'Removes a question from the survey.', {
              notes: "Returns a `204 No Content` on success"
            }
            params do
              use :auth
              use :survey_id
              use :question_id
            end
            delete '/' do
              validate_user!
              survey = load_survey!
              survey.questions_surveys.where(question_atts).delete_all
              status 204
            end
          end
        end
      end
    end
  end
end
