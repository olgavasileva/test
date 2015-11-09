require 'google/api_client'
require 'date'
module GoogleanalyticsHelper
SERVICE_ACCOUNT_EMAIL_ADDRESS = '827188703427-v7km3qvj0hpkesukpdtpsujl4ga1rf8s@developer.gserviceaccount.com' # looks like 12345@developer.gserviceaccount.com
KEY_FILE_CONTENTS           = Rails.root.join('config','StatisfyAnalyticsAPIClient-4b494c30b250.p12').to_s # the path to the downloaded .p12 key file
PROFILE                       = 'ga:96256016'#'ga:89932222' # Statisfy.co - 89932222

def google_analytics_report (date_range_metrics)
	@start_date = date_range_metrics[:date_from]
	@end_date = date_range_metrics[:date_to]

@usersTotal = 0
@viewsTotal = 0

	#response = get_result('ga:users, ga:pageviews', @start_date, @end_date )
	response = get_result('ga:totalEvents, ga:users', @start_date, @end_date )
	# ga:totalEvents


	columns = Hash.new{}
	column_index = 0
	response.data['columnHeaders'].each do | column_header_index | 
		columns[column_header_index['name']] = column_index
		column_index = column_index + 1
	end
#columns.delete('ga:eventAction')
## Seed the hash with zero's for the date so that there is always
## a key in the structure for that day
@hash_ga  = Hash.new
(@start_date..@end_date).each do | date |
		this_data = Hash.new{}
		columns.each do | fk, fv |
			this_data[ fk ] = 0
		end
end	

	response.data['rows'].each do | row |
	#	remove_column row[columns['ga:eventAction']]
	#row.delete_at(0)	
	key = Date.parse( row[ columns[ 'ga:date' ] ] ).strftime( "%Y-%m-%d")
		this_data = Hash.new{}
		columns.each do | fk, fv |
			pp fk
			pp fv
		#	remove_column 'view'
			this_data[ fk ] = row[ fv ]
		end
		#pp this_data
		@hash_ga[key] = this_data
	end
	return @hash_ga

end

def get_client	
	# set up a client instance
	client  = Google::APIClient.new( 
  	:application_name     => 'speedy-bonsai-87321',
  	:application_version  => '0.01'
	)
	
	client.authorization = Signet::OAuth2::Client.new(
  	:token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  	:audience             => 'https://accounts.google.com/o/oauth2/token',
  	:scope                => 'https://www.googleapis.com/auth/analytics.readonly',
  	:issuer               => SERVICE_ACCOUNT_EMAIL_ADDRESS,
  	:signing_key          => Google::APIClient::PKCS12.load_key(KEY_FILE_CONTENTS, 'notasecret')
	).tap { |auth| auth.fetch_access_token! }
	client
end

def get_result(metrics, start_date, end_date)
client = self.get_client
api_method = client.discovered_api('analytics','v3').data.ga.get


	result = client.execute(:api_method => api_method, :parameters => {
	  	'ids'        => PROFILE,
  		'start-date' => Date.parse( start_date ).strftime( "%Y-%m-%d"),
  		'end-date'   => Date.parse( end_date ).strftime(  "%Y-%m-%d"),
 		'metrics'    => metrics,
		'dimensions' => 'ga:date, ga:eventAction', #, ga:date',
		'filters'    => 'ga:eventAction==view'
                #'sort'       => 'ga:date'
})
return result
end

end
 #, @gaPageviews
