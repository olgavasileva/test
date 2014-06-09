class QuestionsController < ApplicationController
	before_action :signed_in_user, only: [:index, :responses, :toggle_hidden, :submit_answer]

	def index
		@questions = Question.paginate(page: params[:page]).order(:id)
	end	

	def show
		@question = Question.find(params[:id])
		if signed_in?
			@answer = Answer.where(question_id: @question.id, user_id: @current_user.id).last
		end

		if params[:sender]
			if User.exists?(:id => params[:sender])
				@user = User.find(params[:sender])
			end
			
		end
	end

	def responses
		@question = Question.find(params[:id])

		@all_results = []
		@question.choices.each do |choice|
			order_average = Response.where(choice_id: choice.id).average("order")
			percent_average = Response.where(choice_id: choice.id).average("percent")
			star_average = Response.where(choice_id: choice.id).average("star")
			slider_average = Response.where(choice_id: choice.id).average("slider")
			@all_results << {:id => choice.id, :order_average => order_average, :percent_average => percent_average, :star_average => star_average, :slider_average => slider_average}
		end

		@response_count = Answer.where(question_id: @question.id).count
	end

	def toggle_hidden(page = 1)
		@question = Question.find(params[:id])
		if @question.hidden
			@question.hidden = false
			flash[:success] = "Question made visible"
		else
			@question.hidden = true
			flash[:success] = "Question hidden"
		end
		@question.save
		
		redirect_to :back
	end

	def submit_answer
		@question = Question.find(params[:id])

		@choice1 = Choice.find(params[:choice_id_1])
		@choice2 = Choice.find(params[:choice_id_2])

		success = false

		ActiveRecord::Base.transaction do
				@answer = @current_user.answers.build(question_id: @question.id)
				success = @answer.save
				@response1 = @answer.responses.build(choice_id: @choice1.id, order: 0, percent: 0, star: 0, slider: params[:slider_amount_1])
				@response2 = @answer.responses.build(choice_id: @choice2.id, order: 0, percent: 0, star: 0, slider: params[:slider_amount_2])
				success = @response1.save && success
				success = @response2.save && success
		end
		
		if success

			flash[:success] = "Success: You answered Choice #{@choice1.label}: #{params[:slider_amount_1]}, and Choice #{@choice2.label}: #{params[:slider_amount_2]}"
			redirect_to responses_question_path(@question)

		else
			flash[:error] = "You've already answered this question and cannot answer it again!"
			redirect_to responses_question_path(@question)
		end
		
	end

end
