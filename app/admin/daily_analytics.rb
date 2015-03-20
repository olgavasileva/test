ActiveAdmin.register DailyAnalytic do
  actions :index

  #Index scopes
  scope :all, default: true
  scope :views
  scope :starts
  scope :responses

  config.sort_order = 'date ASC'

  index do
    column :date
    column :metric
    column :total
    column :graph do |da|
      total = da.total.to_i
      stars = 1 + da.total.to_i / 10
      max_stars = 50
      out = '*' * [stars, max_stars].min
      out += "...*" if stars > max_stars
      out
    end
  end

end