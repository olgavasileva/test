class ListicleDetailsReport < DashboardReport

  private

  def get_report
    @report[:views] = get_views
  end

  def get_views
    views = {}
    @question_ids.each_slice(QUESTIONS_LIMIT).each do |question_ids|
      response = get_google_response('start-date' => start_date.to_s,
                                     'end-date' => end_date.to_s,
                                     'dimensions' => 'ga:eventLabel,ga:eventCategory,ga:eventAction',
                                     'filters' => "ga:eventAction==view;ga:eventCategory==listicle;ga:eventLabel=~#{join_regex_rules(question_ids)}",
                                     'metrics' => 'ga:sessions')
      response.data['rows'].each do |r|
        views[r[0].to_i] = r[3].to_i
      end
      question_ids.each {|id| views[id] = views[id] || 0 }
    end
    views
  end
end