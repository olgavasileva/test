class DemographicObserver < ActiveRecord::Observer
  def after_create demographic
    update_demographic_summary! demographic.respondent
  end

  def after_update demographic
    update_demographic_summary! demographic.respondent
  end

  def after_destroy demographic
    update_demographic_summary! demographic.respondent
  end

  private
    def update_demographic_summary! respondent
      DemographicSummary.where(respondent: respondent).first_or_create.calculate!
    end
end