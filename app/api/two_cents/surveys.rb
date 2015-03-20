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
        requires :survey, type: Hash do
          send(type, :name, type: String, desc: 'The name for the survey')
        end
      end

      params :unit_uuid do |opts|
        requires :uuid, type: String, desc: 'The EmbeddableUnit uuid.'
      end

      params :unit do |opts|
        type = opts[:type] || :optional
        requires :embeddable_unit, type: Hash do
          optional :width, type: Integer, desc: 'The width for the embed'
          optional :height, type: Integer, desc: 'The height for the embed'
          send(type, :thank_you_markdown, {
            desc: 'The thank you message in Markdown format'
          })
        end
      end

      def load_survey!
        Survey.find(params[:survey_id])
      end

      def load_embeddable_unit!
        finders = {uuid: params[:uuid], survey_id: params[:survey_id]}
        EmbeddableUnit.find_by!(finders)
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
        @survey = Survey.create!(declared_params[:survey])
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
                "name": "Soda Pop Questionaire",
                "quesitons": [], // Array of questions,
                "embeddable_units": [] // See GET /surveys/:survey_id/units/:uuid
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
          @survey.update!(declared_params[:survey])
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

        resource :units do

          # ----------------------------------------------------------------------
          # Embeddable Units: Create
          #
          desc 'Create an embeddable unit', {
            notes: "See `GET /surveys/:survey_id/units/:uuid` for example response."
          }
          params do
            use :auth
            use :survey_id
            use :unit, type: :requires
          end
          post '/', jbuilder: 'embeddable_unit' do
            validate_user!
            survey = load_survey!
            @unit = survey.embeddable_units.create!(declared_params[:embeddable_unit])
          end

          route_param :uuid do

            # ----------------------------------------------------------------------
            # Embeddable Units: Retreive
            #
            desc 'Retrieve an embeddable unit', {
              notes: <<-NOTES
                ### Example Response
                ```
                {
                  "embeddable_unit": {
                    "uuid": "EU...",
                    "width": 300,
                    "height": 250,
                    "thank_you_markdown": "**Thanks**",
                    "thank_you_html": "<strong>Thanks</strong>"
                  }
                }
                ```
              NOTES
            }
            params do
              use :auth
              use :survey_id
              use :unit_uuid
            end
            get '/', jbuilder: 'embeddable_unit' do
              validate_user!
              @unit = load_embeddable_unit!
            end

            # ----------------------------------------------------------------------
            # Embeddable Units: Update
            #
            desc 'Updates an embeddable unit', {
              notes: "See `GET /surveys/:survey_id/units/:uuid` for example response."
            }
            params do
              use :auth
              use :survey_id
              use :unit_uuid
              use :unit, type: :optional
            end
            put '/', jbuilder: 'embeddable_unit' do
              validate_user!
              @unit = load_embeddable_unit!
              @unit.update!(declared_params[:embeddable_unit])
            end

            # ----------------------------------------------------------------------
            # Embeddable Units: Delete
            #
            desc 'Deletes an embeddable unit', {
              notes: 'Returns a `204 No Content` status only on success.'
            }
            params do
              use :auth
              use :survey_id
              use :unit_uuid
            end
            delete '/' do
              validate_user!
              unit = load_embeddable_unit!
              unit.destroy!
              status 204
            end
          end
        end
      end
    end
  end
end
