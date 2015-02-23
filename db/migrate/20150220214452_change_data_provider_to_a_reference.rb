class ChangeDataProviderToAReference < ActiveRecord::Migration
  def up
    rename_column :demographics, :data_provider, :old_data_provider
    add_reference :demographics, :data_provider, index: true

    begin
      Demographic.reset_column_information
      quantcast = DataProvider.where(name:'quantcast').first_or_create
      Demographic.all.each {|d| d.update_attributes data_provider_id: quantcast.id if d.old_data_provider == 'quantcast'}
    rescue Exception => e
    end

    remove_column :demographics, :old_data_provider
  end

  def down
    add_column :demographics, :new_data_provider, :string

    begin
      Demographic.reset_column_information
      Demographic.all.each {|d| d.update_attribute :new_data_provider, d.data_provider.try(:name)}
    rescue Exception => e
    end

    rename_column :demographics, :new_data_provider, :data_provider
    remove_column :demographics, :data_provider_id
  end
end
