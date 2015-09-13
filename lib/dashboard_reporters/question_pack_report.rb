class QuestionPackReport < DashboardReport

  private

  def get_report
    surveys.each do |survey|
      @report[survey.id] = {}
    end
    set_views
    set_shares
    set_completes
    set_traffic
    set_time
  end

  def set_views
    survey_questions_ids.each do |survey_id, question_ids|
      response = get_google_response('start-date' => start_date.to_s,
                                     'end-date' => end_date.to_s,
                                     'dimensions' => 'ga:eventCategory,ga:eventAction',
                                     'filters' => "ga:eventAction==view;ga:eventCategory==webapp;ga:eventLabel=~#{join_regex_rules(question_ids)}",
                                     'metrics' => 'ga:totalEvents')
      @report[survey_id][:views] = begin
        response.data['totalsForAllResults']['ga:totalEvents'].to_i
      rescue
        0
      end
    end

  end

  def set_shares
    survey_questions_ids.each do |survey_id, question_ids|
      response = get_google_response('start-date' => start_date.to_s,
                                     'end-date' => end_date.to_s,
                                     'dimensions' => 'ga:eventCategory,ga:eventAction',
                                     'filters' => "ga:eventAction==share;ga:eventCategory==webapp;ga:eventLabel=~#{question_ids.join('$|')}",
                                     'metrics' => 'ga:totalEvents')
      @report[survey_id][:shares] = begin
        response.data['totalsForAllResults']['ga:totalEvents'].to_i
      rescue
        0
      end
    end
  end

  def set_completes
    survey_main_questions_ids.each do |survey_id, question_id|
      response = get_google_response('start-date' => start_date.to_s,
                                     'end-date' => end_date.to_s,
                                     'dimensions' => 'ga:eventCategory,ga:eventAction',
                                     'filters' => "ga:eventAction==end;ga:eventCategory==webapp;ga:eventLabel=~^#{question_id}$)}",
                                     'metrics' => 'ga:totalEvents')
      @report[survey_id][:completes] = begin
        response.data['totalsForAllResults']['ga:totalEvents'].to_i
      rescue
        0
      end
    end
  end

  def set_traffic
    survey_questions_ids.each do |survey_id, question_ids|
      response = get_google_response('start-date' => start_date.to_s,
                                     'end-date' => end_date.to_s,
                                     'dimensions' => 'ga:eventCategory,ga:eventLabel',
                                     'filters' => "ga:eventCategory==webapp;ga:eventLabel=~#{question_ids.join('$|')}",
                                     'metrics' => 'ga:sessions')
      @report[survey_id][:traffic] = begin
        response.data['rows'].map { |x| x[2].to_i }.compact.inject(:+)
      rescue
        0
      end
    end
  end

  def set_time
    0 # not implemented
  end

  def surveys
    @surveys ||= @user.valid_surveys
  end

  def question_ids
    surveys.map(&:question_ids)
  end

  def survey_questions_ids
    return @survey_questions_ids if @survey_questions_ids
    @survey_questions_ids = {}
    surveys.each do |survey|
      @survey_questions_ids[survey.id] = survey.question_ids.take(QUESTIONS_LIMIT)
    end
    @survey_questions_ids
  end

  def survey_main_questions_ids
    return @survey_main_questions_ids if @survey_main_questions_ids
    @survey_main_questions_ids = {}
    surveys.each { |survey| @survey_main_questions_ids[survey.id] = survey.question_ids.first }
    @survey_main_questions_ids
  end

end