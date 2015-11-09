def show
questions = {} 
#	return 
	 Question.where(count:(Question.where(created_at:(Time.now.midnight-30.day..Time.now.midnight).count)), created_at:(Time.now.midnight-30.day..Time.now.midnight)).each do |row| 

end
