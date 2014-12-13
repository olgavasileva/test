class CommentsController < ApplicationController
  skip_after_action :verify_authorized
  def create
    @commentable = find_commentable
    @comment = @commentable.comments.build(comment_params)
    if @comment.save
      flash[:notice] = "Successfully saved comment."
      redirect_to :back
    else
      flash[:error] = "Your comment was not saved. Please try again."
      redirect_to :back
    end
  end

  def find_commentable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
    nil
  end

  private

  def comment_params
    params.require(:comment).permit!
  end
end