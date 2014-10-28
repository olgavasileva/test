class QuestionsControllerBase < ApplicationController
  def new
    @question = question_class.send :new, user:current_user
    authorize @question
    after_build_new @question
  end

  def create
    @question = question_class.send :new, safe_params.merge(user_id:current_user.id, state:params[:commit] == "Preview" ? "preview" : "targeting")
    authorize @question

    if @question.save
      redirect_to @question.preview? ? new_question_response_path(@question) : [:target, @question]
    else
      flash[:error] = @question.errors.full_messages.join('; ')
      render "new"
    end
  end

  def edit
    @question = question_class.send :find, params[:id]
    authorize @question
  end

  def update
    @question = question_class.send :find, params[:id]
    authorize @question

    if @question.update safe_params.merge(state:params[:commit] == "Preview" ? "preview" : "targeting")
      redirect_to @question.preview? ? new_question_response_path(@question) : [:target, @question]
    else
      flash[:error] = "There was a problem updating your question."
      render :edit
    end
  end

  def target
    @question = question_class.send :find, params[:id]
    authorize @question

    if session[:use_enterprise_targeting]
      redirect_to new_question_enterprise_target_path(@question)
    else
      redirect_to new_question_target_path(@question)
    end
  end

  def share
    @question = question_class.send :find, params[:id]
    authorize @question
  end


  def enable
    @question = question_class.send :find, params[:id]
    authorize @question

    if @question.update_attributes state:"active"
      flash[:error] = "The question is now active."
      redirect_to :root
    else
      flash[:error] = "There was a problem enabling your question."
      render :edit
    end
  end

  protected
    def question_class
      raise NotImplementedError.new("You must implement question_class.")
    end

    def after_build_new question
      # override if needed
    end

    def safe_params
      raise NotImplementedError.new("You must implement safe_params.")
    end
end
