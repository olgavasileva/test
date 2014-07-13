class API::QuestionsController < ApplicationController
	skip_before_action :verify_authenticity_token
	before_action :valid_remember_token

	def next10
		if check_next10_params
			@questions = Question.where("hidden IS NULL OR hidden = ?", false).order("RANDOM()").first(10)
			render :json => { :success => @questions }, :status => 200
		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def next10WithPacks
		#no params to check
		baseQuestions = Question.where("hidden IS NULL OR hidden = ?", false).order("RANDOM()")
		@questions = []
		@inclusions = []
		@packs = []

		countedQuestions = []

		baseQuestions.each do |question|

			myAnswer = Answer.where(question_id: question.id, user_id: @current_user.id).last

			unless myAnswer
				unless countedQuestions.count > 14
					countedQuestions.push(question)

					if question.packs.any?
						randomPack = question.packs.sample
						unless @packs.include?(randomPack)
							@packs.push(randomPack)
						end
						packInclusions = Inclusion.where(pack_id: randomPack.id)
						packInclusions.each do |packInclusion|
							packQuestion = Question.where(id: packInclusion.question_id).last
							unless @questions.include?(packQuestion)
								@questions.push(packQuestion)
								@inclusions.push(packInclusion)
							end
						end
					else
						@questions.push(question)
					end
				end
			end
			
		end

		render :json => { :success => { :questions => @questions, :inclusions => @inclusions, :packs => @packs } }, :status => 200
	end




	def question_feed
		# set up arrays for sourcing question feed

		baseQuestions = []
		friendQuestions = []
		@questions = []
		@packs = []
		@inclusions = []
		@specialCaseReturned = []
		@sponsoredReturned = []
		@twoCentsReturned = []
		@friendReturned = []
		@trendingReturned = []


		# Query for all buckets Except Trending 

		specialCaseQuestions = Question.where("(hidden IS NULL OR hidden = ?) AND (special_case = ?) AND id NOT IN (?)", false, true, Answer.select("question_id").where(user_id: @current_user.id)).order("RANDOM()").limit(15)

		sponsoredQuestions = Question.where("(hidden IS NULL OR hidden = ?) AND (sponsored = ?) AND id NOT IN (?)", false, true, Answer.select("question_id").where(user_id: @current_user.id)).order("RANDOM()").limit(1)

		twoCentsQuestions = Question.where("(hidden IS NULL OR hidden = ?) AND user_id = 1 AND id NOT IN (?)", false, Answer.select("question_id").where(user_id: @current_user.id)).order("RANDOM()").limit(1)

		randomQuestions = Question.where("(hidden IS NULL OR hidden = ?) AND id NOT IN (?)", false, Answer.select("question_id").where(user_id: @current_user.id)).order("RANDOM()").limit(30)

		createdAndShared = Question.joins("JOIN sharings ON sharings.question_id = questions.id").where("(hidden IS NULL OR hidden = ?) AND (sharings.receiver_id = ?) AND (user_id IN (?)) AND (questions.id NOT IN (?))", false, @current_user.id, User.select("users.id").joins("JOIN friendships ON friendships.friend_id = users.id").where("friendships.user_id = ?", @current_user.id), Answer.select("question_id").where(user_id: @current_user.id)).order("RANDOM()").limit(7)

		answeredAndShared = Question.joins("JOIN answers ON answers.question_id = questions.id").joins("JOIN sharings ON sharings.question_id = questions.id").where("(hidden IS NULL OR hidden = ?) AND (sharings.receiver_id = ?) AND (answers.user_id IN (?)) AND (questions.id NOT IN (?))", false, @current_user.id, User.select("users.id").joins("JOIN friendships ON friendships.friend_id = users.id").where("friendships.user_id = ?", @current_user.id), Answer.select("question_id").where(user_id: @current_user.id) ).order("RANDOM()").limit(7)

		createdAndNotShared = Question.where("(hidden IS NULL OR hidden = ?) AND (questions.id NOT IN (?)) AND (user_id IN (?)) AND (questions.id NOT IN (?))", false, Sharing.select("question_id").where("receiver_id = ?", @current_user.id), User.select("users.id").joins("JOIN friendships ON friendships.friend_id = users.id").where("friendships.user_id = ?", @current_user.id), Answer.select("question_id").where(user_id: @current_user.id)).order("RANDOM()").limit(7)


		# Query for Trending Bucket

		trendingIDrecords = ActiveRecord::Base.connection.execute("SELECT id FROM
(
SELECT answer_query.id, answer_count, comment_count, sharing_count, (answer_count + (comment_count / 2) + (sharing_count / 2)) AS trending_score

FROM
(SELECT q.id, count(a.id) AS answer_count
FROM questions q
LEFT JOIN answers a ON a.question_id = q.id
WHERE a.created_at >= current_date - interval '2 days'
AND q.created_at <= current_date - interval '2 days'
GROUP BY q.id
ORDER BY answer_count DESC) AS answer_query

LEFT JOIN 
(SELECT q.id, count(c.id) AS comment_count
FROM questions q
LEFT JOIN comments c ON c.question_id = q.id
WHERE c.created_at >= current_date - interval '2 days'
AND q.created_at <= current_date - interval '2 days'
GROUP BY q.id
ORDER BY comment_count DESC) AS comment_query
ON answer_query.id = comment_query.id

LEFT JOIN
(SELECT id, count(sender_id) AS sharing_count
FROM
(SELECT q.id, sender_id
FROM questions q
LEFT JOIN sharings s ON s.question_id = q.id
WHERE s.created_at >= current_date - interval '2 days'
AND q.created_at <= current_date - interval '2 days'
GROUP BY q.id, sender_id) AS sender_questions
GROUP BY id
ORDER BY sharing_count DESC) AS sharing_query
ON answer_query.id = sharing_query.id

WHERE (answer_count > 0) 
OR (comment_count > 0) 
OR (sharing_count > 0)

ORDER BY trending_score DESC
LIMIT 10
) AS trending_query")

		trendingIDarray = []
		trendingIDrecords.each do |id|
			trendingIDarray.push(id["id"])
		end
		trendingQuestions = Question.where("(hidden IS NULL OR hidden = ?) AND id IN (?)", false, trendingIDarray).order("RANDOM()")


		# source special_case, sponsored, and twoCents Qs

		specialCaseQuestions.each do |question|
			unless baseQuestions.include?(question)
				unless baseQuestions.count > 14
					baseQuestions.push(question)
					@specialCaseReturned.push(question)
				end
			end
		end

		if sponsoredQuestions.count > 0
			unless baseQuestions.include?(sponsoredQuestions.last)
				unless baseQuestions.count > 14
					baseQuestions.push(sponsoredQuestions.last)
					@sponsoredReturned.push(sponsoredQuestions.last)
				end
			end
		end

		if twoCentsQuestions.count > 0
			unless baseQuestions.include?(twoCentsQuestions.last)
				unless baseQuestions.count > 14
					baseQuestions.push(twoCentsQuestions.last)
					@twoCentsReturned.push(twoCentsQuestions.last)
				end
			end
		end


		# source Friend Qs

		createdAndShared.each do |question|
			unless friendQuestions.include?(question)
				unless friendQuestions.count > 6
					friendQuestions.push(question)
				end
			end
		end

		answeredAndShared.each do |question|
			unless friendQuestions.include?(question)
				unless friendQuestions.count > 6
					friendQuestions.push(question)
				end
			end
		end

		createdAndNotShared.each do |question|
			unless friendQuestions.include?(question)
				unless friendQuestions.count > 6
					friendQuestions.push(question)
				end
			end
		end

		friendQuestions.each do |question|
			unless baseQuestions.include?(question)
				unless baseQuestions.count > 14
					baseQuestions.push(question)
					@friendReturned.push(question)
				end
			end
		end


		# source Trending Q

		addedTrendingQuestion = false
		trendingQuestions.each do |question|
			unless baseQuestions.include?(question)
				unless baseQuestions.count > 14
					unless addedTrendingQuestion
						baseQuestions.push(question)
						@trendingReturned.push(question)
						addedTrendingQuestion = true
					end
				end
			end
		end


		# source Random Qs

		randomQuestions.each do |question|
			unless baseQuestions.include?(question)
				unless baseQuestions.count > 14
					baseQuestions.push(question)
				end
			end
		end

		# shuffle questions

		baseQuestions = baseQuestions.shuffle

		resortedQuestions = []
		friendCount = 0
		baseQuestions.each do |question|
			if @trendingReturned.include?(question)
				resortedQuestions.push(question)
			elsif (@friendReturned.include?(question) and friendCount < 2)
				resortedQuestions.push(question)
				friendCount += 1
			elsif @specialCaseReturned.include?(question)
				resortedQuestions.push(question)
			elsif @sponsoredReturned.include?(question)
				resortedQuestions.push(question)
			elsif @twoCentsReturned.include?(question)
				resortedQuestions.push(question)
			end
		end

		baseQuestions.each do |question|
			unless resortedQuestions.include?(question)
				resortedQuestions.push(question)
			end
		end

		baseQuestions = resortedQuestions

		# add pack questions for any Pack questions included in feed

		countedQuestions = []

		baseQuestions.each do |question|
			unless @questions.include?(question)
				countedQuestions.push(question)
			end

			trendingPack = false
			if @trendingReturned.include?(question)
				trendingPack = true
			end

			friendPack = false
			if @friendReturned.include?(question)
				friendPack = true
			end

			if question.packs.any?
				randomPack = question.packs.sample
				unless @packs.include?(randomPack)
					@packs.push(randomPack)
				end
				packInclusions = Inclusion.where(pack_id: randomPack.id)
				packInclusions.each do |packInclusion|
					packQuestion = Question.where(id: packInclusion.question_id).last
					unless @questions.include?(packQuestion)
						@questions.push(packQuestion)
						@inclusions.push(packInclusion)
					end

					if trendingPack
						unless @trendingReturned.include?(packQuestion)
							@trendingReturned.push(packQuestion)
						end
					end

					if friendPack
						unless @friendReturned.include?(packQuestion)
							@friendReturned.push(packQuestion)
						end
					end
					
				end
			else
				@questions.push(question)
			end
		end


		# make sure feed has 15 top level questions

		if countedQuestions.count < 15
			randomQuestions.each do |question|
				unless question.packs.any?
					unless @questions.include?(question)
						unless countedQuestions.count > 14
							@questions.push(question)
							countedQuestions.push(question)
						end
					end
				end
			end
		end


		# render and return JSON question feed to user

		render :json => { :success => { :questions => @questions, :inclusions => @inclusions, :packs => @packs, :special_case => @specialCaseReturned, :sponsored => @sponsoredReturned, :two_cents => @twoCentsReturned, :friend => @friendReturned, :trending => @trendingReturned } }, :status => 200
	end




	def results
		#no params to check
		@question = Question.find_by(id: params[:id])

		choice_results = []
		@question.choices.each do |choice|
			order_average = Response.where(choice_id: choice.id).average("order")
			percent_average = Response.where(choice_id: choice.id).average("percent")
			star_average = Response.where(choice_id: choice.id).average("star")
			slider_average = Response.where(choice_id: choice.id).average("slider")
			choice_results << {:id => choice.id, :order_average => order_average, :percent_average => percent_average, :star_average => star_average, :slider_average => slider_average}
		end

		total_results = @question.answers.count

		render :json => { :success => { :results => { :choices => choice_results, :count => total_results } } }, :status => 200
	end

	def results_v2
		#no params to check
		@question = Question.find_by(id: params[:id])
		total_results = @question.answers.count

		all_results = []
		my_results = []
		@question.choices.each do |choice|
			order_average = Response.where(choice_id: choice.id).average("order")
			percent_average = Response.where(choice_id: choice.id).average("percent")
			star_average = Response.where(choice_id: choice.id).average("star")
			slider_average = Response.where(choice_id: choice.id).average("slider")
			all_results << {:id => choice.id, :order_average => order_average, :percent_average => percent_average, :star_average => star_average, :slider_average => slider_average}
		end

		my_answer = Answer.where(question_id: @question.id, user_id: @current_user.id).last
		if my_answer
			my_answer.responses.each do |response|
				my_results << { :choice_id => response.choice_id, :order => response.order, :slider => response.slider, :star => response.star, :percent => response.percent }
			end

			render :json => { :success => { :results => { :choices => all_results, :my_responses => my_results, :count => total_results } } }, :status => 200
		else
			render :json => { :success => { :results => { :choices => all_results, :count => total_results } } }, :status => 200
		end
	end

	def questions_asked
		#no params to check
		@questions = Question.where(user_id: current_user.id).order("RANDOM()").first(10)
		render :json => { :success => { :questions => @questions } }
	end

	def questions_answered
		#no params to check
		
		#answers = Answer.where(user_id: current_user.id).group("question_id").order("RANDOM()").first(10)
		answers = Answer.where(user_id: current_user.id).order("RANDOM()").first(10)
		@questions = []
		answers.each do |answer|
			answeredQuestion = Question.where(id: answer.question_id).last
			unless @questions.include?(answeredQuestion)
				@questions.push(answeredQuestion)
			end
		end

		render :json => { :success => { :questions => @questions } }
	end

	def ask_question_type_1
		if check_ask_question_type_1_params
			@question = @current_user.questions.build(question_params)

			if @question.save

				@choice1 = @question.choices.build(choice1_params)
				@choice2 = @question.choices.build(choice2_params)
				@choice3 = @question.choices.build(choice3_params)
				@choice4 = @question.choices.build(choice4_params)

				if @choice1.save
					if @choice2.save
						if @choice3.save
							if @choice4.save
								
								render :json => { :success => { :question => @question } }, :status => 200

							else
								render :json => { :error => "internal-server-error: question creation" }, :status => 500
							end
						else
							render :json => { :error => "internal-server-error: question creation" }, :status => 500
						end
					else
						render :json => { :error => "internal-server-error: question creation" }, :status => 500
					end
				else
					render :json => { :error => "internal-server-error: question creation" }, :status => 500
				end
			else
				render :json => { :error => "internal-server-error: question creation" }, :status => 500
			end

		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def ask_question_type_2
		if check_ask_question_type_2_params
			@question = @current_user.questions.build(question_params)

			if @question.save

				@choice1 = @question.choices.build(choice1_params)
				@choice2 = @question.choices.build(choice2_params)

				if @choice1.save
					if @choice2.save

						render :json => { :success => { :question => @question } }, :status => 200
					else
						render :json => { :error => "internal-server-error: question creation" }, :status => 500
					end
				else
					render :json => { :error => "internal-server-error: question creation" }, :status => 500
				end
			else
				render :json => { :error => "internal-server-error: question creation" }, :status => 500
			end

		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def ask_question_type_3
		if check_ask_question_type_3_params
			@question = @current_user.questions.build(question_params)

			if @question.save

				@choice1 = @question.choices.build(choice1_params)
				@choice2 = @question.choices.build(choice2_params)
				@choice3 = @question.choices.build(choice3_params)
				@choice4 = @question.choices.build(choice4_params)

				if @choice1.save
					if @choice2.save
						if @choice3.save
							if @choice4.save
								
								render :json => { :success => { :question => @question } }, :status => 200

							else
								render :json => { :error => "internal-server-error: question creation" }, :status => 500
							end
						else
							render :json => { :error => "internal-server-error: question creation" }, :status => 500
						end
					else
						render :json => { :error => "internal-server-error: question creation" }, :status => 500
					end
				else
					render :json => { :error => "internal-server-error: question creation" }, :status => 500
				end
			else
				render :json => { :error => "internal-server-error: question creation" }, :status => 500
			end

		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def ask_question_type_4
		if check_ask_question_type_4_params
			@question = @current_user.questions.build(question_params)

			if @question.save

				@choice1 = @question.choices.build(choice1_params)
				@choice2 = @question.choices.build(choice2_params)
				@choice3 = @question.choices.build(choice3_params)
				@choice4 = @question.choices.build(choice4_params)
				@choice5 = @question.choices.build(choice5_params)

				if @choice1.save
					if @choice2.save
						if @choice3.save
							if @choice4.save
								if @choice5.save
									render :json => { :success => { :question => @question } }, :status => 200
								else
									render :json => { :error => "internal-server-error: question creation" }, :status => 500
								end
							else
								render :json => { :error => "internal-server-error: question creation" }, :status => 500
							end
						else
							render :json => { :error => "internal-server-error: question creation" }, :status => 500
						end
					else
						render :json => { :error => "internal-server-error: question creation" }, :status => 500
					end
				else
					render :json => { :error => "internal-server-error: question creation" }, :status => 500
				end
			else
				render :json => { :error => "internal-server-error: question creation" }, :status => 500
			end

		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def ask_question_type_5
		if check_ask_question_type_5_params
			@question = @current_user.questions.build(question_params)

			if @question.save

				@choice1 = @question.choices.build(choice1_params)
				@choice2 = @question.choices.build(choice2_params)
				@choice3 = @question.choices.build(choice3_params)
				@choice4 = @question.choices.build(choice4_params)
				@choice5 = @question.choices.build(choice5_params)
				@choice6 = @question.choices.build(choice6_params)

				if @choice1.save
					if @choice2.save
						if @choice3.save
							if @choice4.save
								if @choice5.save
									if @choice6.save
										render :json => { :success => { :question => @question } }, :status => 200
									else
										render :json => { :error => "internal-server-error: question creation" }, :status => 500
									end
								else
									render :json => { :error => "internal-server-error: question creation" }, :status => 500
								end
							else
								render :json => { :error => "internal-server-error: question creation" }, :status => 500
							end
						else
							render :json => { :error => "internal-server-error: question creation" }, :status => 500
						end
					else
						render :json => { :error => "internal-server-error: question creation" }, :status => 500
					end
				else
					render :json => { :error => "internal-server-error: question creation" }, :status => 500
				end
			else
				render :json => { :error => "internal-server-error: question creation" }, :status => 500
			end

		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def share_question
		if check_share_question_params
			@sharing = @current_user.sharings.build(sharing_params)
			if @sharing.save
				render :json => { :success => { :sharing => @sharing } }, :status => 200
			else
				render :json => { :error => "internal-server-error: sharing creation" }, :status => 500
			end
		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def shared_with_me
		# no params to check, we want all sharings with no paging
		@reverse_sharings = @current_user.reverse_sharings
		
		@senders = []
		@questions = []
		@reverse_sharings.each do |rev_share|
			sender = rev_share.sender
			unless @senders.include?(sender)
				@senders.push(sender)
			end
			question = rev_share.question
			unless @questions.include?(question)
				@questions.push(question)
			end
		end

		render :json => { :success => { :sharings => @reverse_sharings, :senders => @senders, :questions => @questions } }, :status => 200
	end


	private

		def valid_remember_token
			if params[:udid] && params[:remember_token]
				device = Device.find_by(udid: params[:udid])
				if device
					ownership = Ownership.find_by(device_id: device.id, remember_token: params[:remember_token])
					if ownership
						@current_user = User.find_by(id: ownership.user_id)
					else
						render :json => { :error => "forbidden: invalid session, access denied" }, :status => 403
					end
				else
					render :json => { :error => "forbidden: unregistered device, access denied" }, :status => 403
				end
			else
				render :json => { :error => "forbidden: missing session parameters, access denied" }, :status => 403
			end
		end

		def question_params
			params.require(:question).permit(:title, :info, :image_url, :question_type, :category_id, :min_value, :max_value, :interval, :units, :hidden)
		end

		def choice1_params
			params.require(:choice1).permit(:label, :image_url, :description)
		end

		def choice2_params
			params.require(:choice2).permit(:label, :image_url, :description)
		end

		def choice3_params
			params.require(:choice3).permit(:label, :image_url, :description)
		end

		def choice4_params
			params.require(:choice4).permit(:label, :image_url, :description)
		end

		def choice5_params
			params.require(:choice5).permit(:label, :image_url, :description)
		end

		def choice6_params
			params.require(:choice6).permit(:label, :image_url, :description)
		end

		def sharing_params
			params.require(:sharing).permit(:question_id, :receiver_id)
		end

		def check_next10_params
			params[:page]
		end

		def check_ask_question_type_1_params
			params[:question] && params[:question][:title] && params[:question][:question_type] && params[:question][:category_id] && params[:question][:hidden] && params[:choice1] && params[:choice1][:label] && params[:choice2] && params[:choice2][:label] && params[:choice3] && params[:choice3][:label] && params[:choice4] && params[:choice4][:label]
		end

		def check_ask_question_type_2_params
			params[:question] && params[:question][:title] && params[:question][:question_type] && params[:question][:category_id] && params[:question][:min_value] && params[:question][:max_value] && params[:question][:interval] && params[:question][:hidden] && params[:choice1] && params[:choice1][:label] && params[:choice2] && params[:choice2][:label]
		end

		def check_ask_question_type_3_params
			params[:question] && params[:question][:title] && params[:question][:question_type] && params[:question][:category_id] && params[:question][:hidden] && params[:choice1] && params[:choice1][:label] && params[:choice2] && params[:choice2][:label] && params[:choice3] && params[:choice3][:label] && params[:choice4] && params[:choice4][:label]
		end

		def check_ask_question_type_4_params
			params[:question] && params[:question][:title] && params[:question][:question_type] && params[:question][:category_id] && params[:question][:hidden] && params[:choice1] && params[:choice1][:label] && params[:choice2] && params[:choice2][:label] && params[:choice3] && params[:choice3][:label] && params[:choice4] && params[:choice4][:label] && params[:choice5] && params[:choice5][:label]
		end

		def check_ask_question_type_5_params
			params[:question] && params[:question][:title] && params[:question][:question_type] && params[:question][:category_id] && params[:question][:hidden] && params[:choice1] && params[:choice1][:label] && params[:choice2] && params[:choice2][:label] && params[:choice3] && params[:choice3][:label] && params[:choice4] && params[:choice4][:label] && params[:choice5] && params[:choice5][:label] && params[:choice6] && params[:choice6][:label]
		end

		def check_share_question_params
			params[:sharing] && params[:sharing][:question_id] && params[:sharing][:receiver_id]
		end

end