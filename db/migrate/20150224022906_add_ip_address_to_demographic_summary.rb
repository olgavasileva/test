class AddIpAddressToDemographicSummary < ActiveRecord::Migration
  def change
    add_column :demographic_summaries, :ip_address, :string
  end
end
