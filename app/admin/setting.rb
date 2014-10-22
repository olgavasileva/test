ActiveAdmin.register Setting do
  permit_params :enabled, :key, :value

end
