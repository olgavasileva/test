class MaxMind
  # ret = city_db.lookup ip
  # ret.found? # => true
  # ret.country.name # => 'United States'
  # ret.country.name('zh-CN') # => '美国'
  # ret.country.iso_code # => 'US'
  # ret.city.name(:fr) # => 'Mountain View'
  # ret.location.latitude # => -122.0574
  def self.city_db
    @city_db ||= MaxMindDB.new File.join(Figaro.env.GEOIP_PATH, 'GeoIP2-City.mmdb')
  end
end