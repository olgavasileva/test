ActiveAdmin.register Contest do
  menu parent: 'Surveys'

  permit_params :name, :key_question_id, :survey_id, :heading_markdown, :gallery_heading_markdown, :allow_anonymous_votes

  filter :name
  filter :survey

  index do
    column :id
    column :name
    column :key_question
    column "Contest URL" do |c|
      link_to "Contest Sign Up", contest_sign_up_url(c.uuid)
    end
    column "Gallery URL" do |c|
      link_to "Contest Gallery", contest_vote_url(c.uuid)
    end
    column :allow_anonymous_votes
    column do |c|
      link_to 'CSV Report', csv_report_admin_contest_path(c)
    end
    actions
  end

  show do |c|
    attributes_table do
      row :id
      row :name
      row :allow_anonymous_votes
      row "Heading" do
        c.heading_html.to_s.html_safe
      end
      row "Gallery Heading" do
        c.gallery_heading_html.to_s.html_safe
      end

      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :survey
      f.input :key_question, collection: f.object.questions
      f.input :name
      f.input :allow_anonymous_votes
      f.input :heading_markdown
      f.input :gallery_heading_markdown
    end
    f.actions
  end

  # CSV.columns << USER_ID, AGE, GENDER
  # For each question in contest.survey
  #      CSV.columns << question.columnss (based on type)
  #           e.g. [question.id] question.text for regular questions, and a huge list for studio questions
  #
  # Initialize CSV.row
  # For each user who responded to the key question
  #      CSV.row << user.id, user.age, user.gender
  #      For each response to the key question by this user with index
  #           For each question in contest.survey
  #                response = question.responses.where(user:user)[index] or nil
  #                if response
  #                     CSV.columns << response.data_columns
  #                else
  #                     CSV.columns << blank for the data columns
  member_action :csv_report do
    contest = Contest.find params[:id]
    survey = contest.survey

    if !survey
      flash[:notice] = "There is no survey related to this contest"
      redirect_to :back
    else
      headers["Content-Type"] = "text/csv"
      headers["Content-Disposition"] = "attachment"
      headers["Pragma"] = "no-cache"
      headers["Expires"] = "0"

      csv_body = CSV.generate do |csv|

        # Add some overview rows
        csv << ["Contest ID", "Contest Name", "Survey ID", "Survey Name"]
        csv << [contest.id, contest.name, survey.id, survey.name]
        csv << []

        # Build the columns row
        columns = ["User ID", "username", "Age", "Gender"]
        survey.questions.each do |q|
          columns << nil  # blank column before each question
          columns << "Response ID"
          columns += q.csv_columns
        end

        csv << columns

        # Build a line for each respondent
        contest.key_question.respondents.each do |respondent|
          contest.key_question.responses.where(user:respondent).order(:created_at).each_with_index do |key_response, index|
            line = [respondent.id, respondent.username, respondent.age, respondent.gender]
            survey.questions.each do |question|
              responses = question.responses.where(user:respondent)

              line << nil  # blank column before each question

              if responses.count > index
                line << responses[index].id
                line += responses[index].csv_data
              else
                line << nil # blank column
                line += Array.new(question.csv_columns.count)
              end
            end

            csv << line
          end
        end
      end

      render text: csv_body
    end
  end
end
