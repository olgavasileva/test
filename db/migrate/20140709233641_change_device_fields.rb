class ChangeDeviceFields < ActiveRecord::Migration
  def change
    rename_column :devices, :udid, :device_vendor_identifier
    rename_column :devices, :device_type, :platform
    add_column :devices, :manufacturer, :string
    add_column :devices, :model, :string
  end
end
