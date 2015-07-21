class SampleSurveySearcher

  attr_reader :sample_surveys

  def initialize(user, survey, referrer, count = 3)
    @user, @survey, @referrer, @count = user, survey, referrer, count
    @sample_surveys = []
    search_surveys
  end

  def search_surveys
    @sample_surveys = for_any_domain
    if @sample_surveys.length < @count
      settings = Setting.fetch_values('thankyou_suggested_polls') || []
      if settings && !settings.empty?
        surveys_ids = settings.values.first.split ','
        count = @count - @sample_surveys.length
        @sample_surveys += Survey.where(id: surveys_ids)
                               .where.not(id: @sample_surveys.map(&:id)).limit(count).to_a
      end
    end
    @sample_surveys
  end

  private

  def referrer_valid?
    ActiveRecord::Base::sanitize(@referrer.strip).length > 0
  end

  def for_current_domain
    if referrer_valid?
      Survey.find_by_sql(limit(popular_surveys_for_referrer, 2)).to_a
    else
      []
    end
  end

  def limit(query, count)
    query.project(Survey.arel_table[Arel.star]).take(count).to_sql
  end

  def for_any_domain
    query = limit popular_surveys(@sample_surveys), @count - @sample_surveys.length
    Survey.find_by_sql(query).to_a
  end

  # deprecated
  def popular_surveys_for_referrer
    if @referrer && !@referrer.empty?
      responses = Response.arel_table
      popular_surveys.where(responses[:original_referrer].eq(@referrer))
    else
      popular_surveys
    end
  end

  def popular_surveys(except_surveys = [])
    surveys = Survey.arel_table
    questions = Question.arel_table
    questions_surveys = QuestionsSurvey.arel_table
    responses = Response.arel_table
    except_surveys_ids = except_surveys.map(&:id).push @survey.id
    query = surveys
                .join(questions_surveys).on(surveys[:id].eq(questions_surveys[:survey_id]))
                .join(questions).on(questions[:id].eq(questions_surveys[:question_id]))
                .join(responses).on(questions[:id].eq(responses[:question_id]).and(responses[:user_id].not_eq(@user.id)))
    unless except_surveys_ids.empty?
      query = query.where(surveys[:id].not_in(except_surveys_ids))
    end

    query.where(responses[:original_referrer].not_eq(nil)
                    .and(responses[:original_referrer].not_eq(''))
                    .and(responses[:original_referrer].matches('http%//%'))
                    .and(responses[:created_at].gteq(DateTime.now - 1.day)))

    exclusions = begin
      set_values = Setting.fetch_value('related_survey_exclusions') || String.new
      set_values.split ','
    end
    exclusions.each do |exclusion|
      query.where responses[:original_referrer].does_not_match(exclusion)
    end

    query.group(surveys[:id]).order(responses[:id].count.desc)
  end

end