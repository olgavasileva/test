class AddCountryToDemographicSummary < ActiveRecord::Migration
  def change
    add_column :demographic_summaries, :country, :string
    add_index :demographic_summaries, :country

    begin
      DemographicSummary.reset_column_information
      DemographicSummary.where.not(ip_address:nil).find_each do |d|
        d.update_attribute :country, d.country_code
      end
    rescue
    end
  end

  def down
    remove_index :demographic_summaries, :country
    remove_column :demographic_summaries, :country
  end
end
