class AddIpAddressToDemographic < ActiveRecord::Migration
  def change
    add_column :demographics, :ip_address, :string
  end
end
