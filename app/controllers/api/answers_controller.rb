class API::AnswersController < ApplicationController
	skip_before_action :verify_authenticity_token
	before_action :valid_remember_token

	def answer_question_type_1
		if check_answer_question_type_1_params
			@answer = @current_user.answers.build(answer_params)
			if @answer.save
				@response1 = @answer.responses.build(response1_params)
				@response2 = @answer.responses.build(response2_params)
				@response3 = @answer.responses.build(response3_params)
				@response4 = @answer.responses.build(response4_params)
				if @response1.save
					if @response2.save
						if @response3.save
							if @response4.save

								@choice1_average = Response.where(choice_id: @response1.choice_id).average("order")
								@choice2_average = Response.where(choice_id: @response2.choice_id).average("order")
								@choice3_average = Response.where(choice_id: @response3.choice_id).average("order")
								@choice4_average = Response.where(choice_id: @response4.choice_id).average("order")

								@results = { :choices => [ {:id => @response1.choice_id, :order_average => @choice1_average}, {:id => @response2.choice_id, :order_average => @choice2_average}, {:id => @response3.choice_id, :order_average => @choice3_average}, {:id => @response4.choice_id, :order_average => @choice4_average} ] }

								render :json => { :success => { :answer => @answer, :results => @results } }, :status => 200
							else
								render :json => { :error => "internal-server-error: answer creation" }, :status => 500
							end
						else
							render :json => { :error => "internal-server-error: answer creation" }, :status => 500
						end
					else
						render :json => { :error => "internal-server-error: answer creation" }, :status => 500
					end
				else
					render :json => { :error => "internal-server-error: answer creation" }, :status => 500
				end
			else
				render :json => { :error => "internal-server-error: answer creation" }, :status => 500
			end
		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def answer_question_type_2
		if check_answer_question_type_2_params
			@answer = @current_user.answers.build(answer_params)
			if @answer.save
				@response1 = @answer.responses.build(response1_params)
				@response2 = @answer.responses.build(response2_params)
				if @response1.save
					if @response2.save
						
						@choice1_average = Response.where(choice_id: @response1.choice_id).average("slider")
						@choice2_average = Response.where(choice_id: @response2.choice_id).average("slider")

						@results = { :choices => [ {:id => @response1.choice_id, :slider_average => @choice1_average}, {:id => @response2.choice_id, :slider_average => @choice2_average} ] }

						render :json => { :success => { :answer => @answer, :results => @results } }, :status => 200
					else
						render :json => { :error => "internal-server-error: answer creation" }, :status => 500
					end
				else
					render :json => { :error => "internal-server-error: answer creation" }, :status => 500
				end
			else
				render :json => { :error => "internal-server-error: answer creation" }, :status => 500
			end
		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def answer_question_type_3
		if check_answer_question_type_3_params
			@answer = @current_user.answers.build(answer_params)
			if @answer.save
				@response1 = @answer.responses.build(response1_params)
				@response2 = @answer.responses.build(response2_params)
				@response3 = @answer.responses.build(response3_params)
				@response4 = @answer.responses.build(response4_params)
				if @response1.save
					if @response2.save
						if @response3.save
							if @response4.save

								@choice1_average = Response.where(choice_id: @response1.choice_id).average("star")
								@choice2_average = Response.where(choice_id: @response2.choice_id).average("star")
								@choice3_average = Response.where(choice_id: @response3.choice_id).average("star")
								@choice4_average = Response.where(choice_id: @response4.choice_id).average("star")

								@results = { :choices => [ {:id => @response1.choice_id, :star_average => @choice1_average}, {:id => @response2.choice_id, :star_average => @choice2_average}, {:id => @response3.choice_id, :star_average => @choice3_average}, {:id => @response4.choice_id, :star_average => @choice4_average} ] }

								render :json => { :success => { :answer => @answer, :results => @results } }, :status => 200
							else
								render :json => { :error => "internal-server-error: answer creation" }, :status => 500
							end
						else
							render :json => { :error => "internal-server-error: answer creation" }, :status => 500
						end
					else
						render :json => { :error => "internal-server-error: answer creation" }, :status => 500
					end
				else
					render :json => { :error => "internal-server-error: answer creation" }, :status => 500
				end
			else
				render :json => { :error => "internal-server-error: answer creation" }, :status => 500
			end
		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def answer_question_type_4
		if check_answer_question_type_4_params
			@answer = @current_user.answers.build(answer_params)
			if @answer.save
				@response1 = @answer.responses.build(response1_params)
				@response2 = @answer.responses.build(response2_params)
				@response3 = @answer.responses.build(response3_params)
				@response4 = @answer.responses.build(response4_params)
				@response5 = @answer.responses.build(response5_params)
				if @response1.save
					if @response2.save
						if @response3.save
							if @response4.save
								if @response5.save
									@choice1_average = Response.where(choice_id: @response1.choice_id).average("percent")
									@choice2_average = Response.where(choice_id: @response2.choice_id).average("percent")
									@choice3_average = Response.where(choice_id: @response3.choice_id).average("percent")
									@choice4_average = Response.where(choice_id: @response4.choice_id).average("percent")
									@choice5_average = Response.where(choice_id: @response5.choice_id).average("percent")

									@results = { :choices => [ {:id => @response1.choice_id, :percent_average => @choice1_average}, {:id => @response2.choice_id, :percent_average => @choice2_average}, {:id => @response3.choice_id, :percent_average => @choice3_average}, {:id => @response4.choice_id, :percent_average => @choice4_average}, {:id => @response5.choice_id, :percent_average => @choice5_average} ] }

									render :json => { :success => { :answer => @answer, :results => @results } }, :status => 200
								else
									render :json => { :error => "internal-server-error: answer creation" }, :status => 500
								end
							else
								render :json => { :error => "internal-server-error: answer creation" }, :status => 500
							end
						else
							render :json => { :error => "internal-server-error: answer creation" }, :status => 500
						end
					else
						render :json => { :error => "internal-server-error: answer creation" }, :status => 500
					end
				else
					render :json => { :error => "internal-server-error: answer creation" }, :status => 500
				end
			else
				render :json => { :error => "internal-server-error: answer creation" }, :status => 500
			end
		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def answer_question_type_5
		if check_answer_question_type_5_params
			@answer = @current_user.answers.build(answer_params)
			if @answer.save
				@response1 = @answer.responses.build(response1_params)
				@response2 = @answer.responses.build(response2_params)
				@response3 = @answer.responses.build(response3_params)
				@response4 = @answer.responses.build(response4_params)
				@response5 = @answer.responses.build(response5_params)
				@response6 = @answer.responses.build(response6_params)
				if @response1.save
					if @response2.save
						if @response3.save
							if @response4.save
								if @response5.save
									if @response6.save
										@choice1_average = Response.where(choice_id: @response1.choice_id).average("star")
										@choice2_average = Response.where(choice_id: @response2.choice_id).average("star")
										@choice3_average = Response.where(choice_id: @response3.choice_id).average("star")
										@choice4_average = Response.where(choice_id: @response4.choice_id).average("star")
										@choice5_average = Response.where(choice_id: @response5.choice_id).average("star")
										@choice6_average = Response.where(choice_id: @response6.choice_id).average("star")

										@results = { :choices => [ {:id => @response1.choice_id, :star_average => @choice1_average}, {:id => @response2.choice_id, :star_average => @choice2_average}, {:id => @response3.choice_id, :star_average => @choice3_average}, {:id => @response4.choice_id, :star_average => @choice4_average}, {:id => @response5.choice_id, :star_average => @choice5_average}, {:id => @response6.choice_id, :star_average => @choice6_average} ] }

										render :json => { :success => { :answer => @answer, :results => @results } }, :status => 200
									else
										render :json => { :error => "internal-server-error: answer creation" }, :status => 500
									end
								else
									render :json => { :error => "internal-server-error: answer creation" }, :status => 500
								end
							else
								render :json => { :error => "internal-server-error: answer creation" }, :status => 500
							end
						else
							render :json => { :error => "internal-server-error: answer creation" }, :status => 500
						end
					else
						render :json => { :error => "internal-server-error: answer creation" }, :status => 500
					end
				else
					render :json => { :error => "internal-server-error: answer creation" }, :status => 500
				end
			else
				render :json => { :error => "internal-server-error: answer creation" }, :status => 500
			end
		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
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

		def answer_params
			params.require(:answer).permit(:agree, :question_id)
		end

		def response1_params
			params.require(:response1).permit(:choice_id, :order, :percent, :star, :slider)
		end

		def response2_params
			params.require(:response2).permit(:choice_id, :order, :percent, :star, :slider)
		end

		def response3_params
			params.require(:response3).permit(:choice_id, :order, :percent, :star, :slider)
		end

		def response4_params
			params.require(:response4).permit(:choice_id, :order, :percent, :star, :slider)
		end

		def response5_params
			params.require(:response5).permit(:choice_id, :order, :percent, :star, :slider)
		end

		def response6_params
			params.require(:response6).permit(:choice_id, :order, :percent, :star, :slider)
		end

		def check_answer_question_type_1_params
			params[:answer] && params[:answer][:agree] && params[:answer][:question_id] && params[:response1] && params[:response1][:choice_id] && params[:response1][:order] && params[:response1][:percent] && params[:response1][:star] && params[:response1][:slider] && params[:response2] && params[:response2][:choice_id] && params[:response2][:order] && params[:response2][:percent] && params[:response2][:star] && params[:response2][:slider] && params[:response3] && params[:response3][:choice_id] && params[:response3][:order] && params[:response3][:percent] && params[:response3][:star] && params[:response3][:slider] && params[:response4] && params[:response4][:choice_id] && params[:response4][:order] && params[:response4][:percent] && params[:response4][:star] && params[:response4][:slider]
		end

		def check_answer_question_type_2_params
			params[:answer] && params[:answer][:agree] && params[:answer][:question_id] && params[:response1] && params[:response1][:choice_id] && params[:response1][:order] && params[:response1][:percent] && params[:response1][:star] && params[:response1][:slider] && params[:response2] && params[:response2][:choice_id] && params[:response2][:order] && params[:response2][:percent] && params[:response2][:star] && params[:response2][:slider]
		end

		def check_answer_question_type_3_params
			params[:answer] && params[:answer][:agree] && params[:answer][:question_id] && params[:response1] && params[:response1][:choice_id] && params[:response1][:order] && params[:response1][:percent] && params[:response1][:star] && params[:response1][:slider] && params[:response2] && params[:response2][:choice_id] && params[:response2][:order] && params[:response2][:percent] && params[:response2][:star] && params[:response2][:slider] && params[:response3] && params[:response3][:choice_id] && params[:response3][:order] && params[:response3][:percent] && params[:response3][:star] && params[:response3][:slider] && params[:response4] && params[:response4][:choice_id] && params[:response4][:order] && params[:response4][:percent] && params[:response4][:star] && params[:response4][:slider]
		end

		def check_answer_question_type_4_params
			params[:answer] && params[:answer][:agree] && params[:answer][:question_id] && params[:response1] && params[:response1][:choice_id] && params[:response1][:order] && params[:response1][:percent] && params[:response1][:star] && params[:response1][:slider] && params[:response2] && params[:response2][:choice_id] && params[:response2][:order] && params[:response2][:percent] && params[:response2][:star] && params[:response2][:slider] && params[:response3] && params[:response3][:choice_id] && params[:response3][:order] && params[:response3][:percent] && params[:response3][:star] && params[:response3][:slider] && params[:response4] && params[:response4][:choice_id] && params[:response4][:order] && params[:response4][:percent] && params[:response4][:star] && params[:response4][:slider] && params[:response5] && params[:response5][:choice_id] && params[:response5][:order] && params[:response5][:percent] && params[:response5][:star] && params[:response5][:slider]
		end

		def check_answer_question_type_5_params
			params[:answer] && params[:answer][:agree] && params[:answer][:question_id] && params[:response1] && params[:response1][:choice_id] && params[:response1][:order] && params[:response1][:percent] && params[:response1][:star] && params[:response1][:slider] && params[:response2] && params[:response2][:choice_id] && params[:response2][:order] && params[:response2][:percent] && params[:response2][:star] && params[:response2][:slider] && params[:response3] && params[:response3][:choice_id] && params[:response3][:order] && params[:response3][:percent] && params[:response3][:star] && params[:response3][:slider] && params[:response4] && params[:response4][:choice_id] && params[:response4][:order] && params[:response4][:percent] && params[:response4][:star] && params[:response4][:slider] && params[:response5] && params[:response5][:choice_id] && params[:response5][:order] && params[:response5][:percent] && params[:response5][:star] && params[:response5][:slider] && params[:response6] && params[:response6][:choice_id] && params[:response6][:order] && params[:response6][:percent] && params[:response6][:star] && params[:response6][:slider]
		end

end