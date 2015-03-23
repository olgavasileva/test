geoip_path=./geoip
geoip_file_name=GeoIP2-City.mmdb
geoip_url=http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz

if [ ! -d $geoip_path ]; then
  mkdir -p $geoip_path
fi

if [ ! -f $geoip_path/$geoip_file_name ]; then
  wget $geoip_url -O $geoip_path/$geoip_file_name.gz
  gunzip $geoip_path/$geoip_file_name
fi
