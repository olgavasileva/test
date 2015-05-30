class RespondentObserver < ActiveRecord::Observer
  def after_create respondent
    # Add a statisfy demographic record if they provided us with some data
    update_demographics! respondent
  end

  def after_update respondent
    update_demographics! respondent
  end

  private

    def update_demographics! respondent
      if respondent.kind_of?(User) || respondent.kind_of?(Anonymous)
        if respondent.age.present? || respondent.gender.present? || respondent.current_sign_in_ip.present?
          DataProvider.where(name:'statisfy').first_or_create
          d = respondent.demographics.statisfy.first_or_create
          d.age = respondent.age
          d.gender = respondent.gender
          d.ip_address = respondent.current_sign_in_ip
          d.save!
        end
      end
    end
end