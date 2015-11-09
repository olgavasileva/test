include GoogleanalyticsHelper

ActiveAdmin.register_page "regressions" do
menu parent: 'Reports'

  controller do
    def index
	if ( params[:date_from] && params[:date_to] )
		@date_from = Date.parse( params[:date_from] )
		@date_to = Date.parse( params[:date_to] )
		@q = regression_questions_from_db( {:date_from => @date_from, :date_to => @date_to } ) if params[:date_to]
		@l = regression_listicles_from_db( {:date_from => @date_from, :date_to => @date_to } ) if params[:date_to]
      		@t = total_deviation( {:date_from => @date_from, :date_to => @date_to}) if params[:date_to]
		@a = GoogleanalyticsHelper.google_analytics_report({:date_from => params[:date_from], :date_to =>params[:date_to], :metrics => params['ga:users']}) if params[:date_to]



	end
	render 'admin/regression/show', :layout => 'active_admin'
    end

def regression_questions_from_db( date_range )

	@questions = Question.where( created_at: @date_from..@date_to).group( "date( created_at)" ).count(:id )
	@hash_questions = Hash.new
	questions_total = 0.0



	(@date_from..@date_to).each do | date |
		this_data = Hash.new
		this_data['q_answered'] = 0 
		@hash_questions[ date.strftime( "%Y-%m-%d") ] = this_data
	end



	@questions.each do | row |
		questions_total = questions_total + row[1]	
	end

	@questions.each do |dates, quest|
		this_data = Hash.new
	this_data['q_answered'] = quest		
	@hash_questions[dates.strftime("%Y-%m-%d")] = this_data
	end 

return @hash_questions
end


   
def regression_listicles_from_db( date_range )
	@listicles = ListicleResponse.where(created_at: @date_from..@date_to).group( "date( created_at)" ).count(:vote_count) # count(:id )

@hash_listicles = Hash.new
	# See the outer hash so there is always data for each key in the
	# key range
	(@date_from..@date_to).each do | date |
		this_data = Hash.new
		this_data['vote_count'] = 0 
		@hash_listicles[ date.strftime( "%Y-%m-%d") ] = this_data
	end

	@listicles.each do |dates, list|
		this_data = Hash.new
		this_data['vote_count'] = list		
		@hash_listicles[dates.strftime("%Y-%m-%d")] = this_data
	end 

return @hash_listicles
end



def total_deviation(date_range)

	@totals = 0.0
	sum = 0.0
	mean_total = 0.0
	@total_row = Hash.new

	(@date_from..@date_to).each do | date |		
		@totals = @hash_questions[date.to_s]['q_answered'] + @hash_listicles[date.to_s]['vote_count']
		@total_row[date.strftime( "%Y-%m-%d")] = @totals
		sum = sum + @totals
	end
	
	mean = sum/@total_row.length.to_f
	
	@total_row.each do |row|
		mean_total = mean_total + ((row[1] - mean)**2)
	end

	@average = sprintf("%.2f", mean) 
	@stdev = sprintf( "%.2f", Math.sqrt(mean_total.to_f/@total_row.length.to_f))
end


end
end
