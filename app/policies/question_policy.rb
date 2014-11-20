class QuestionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where("questions.user_id = #{user.id} OR questions.anonymous != true")
    end
  end

  def require_user? ; false; end
  def index?  ; true; end
  def summary? ; true; end
  def new?;     @user.present? && !@user.anonymous? && @record.user == @user; end
  def create?;  @user.present? && !@user.anonymous? && @record.user == @user; end
  def edit?;    @user.present? && !@user.anonymous? && @record.user == @user; end
  def update?;  @user.present? && !@user.anonymous? && @record.user == @user; end
  def target?;  @user.present? && !@user.anonymous? && @record.user == @user; end
  def enable?;  @user.present? && !@user.anonymous? && @record.user == @user; end
  def results?;  @user.present? && !@user.anonymous? && @record.user == @user; end
  def preview?;  @user.present? && !@user.anonymous? && @record.user == @user; end
  def update_targetable?; @user.present? && !@user.anonymous? && @record.user == @user; end

  def new_response_from_uuid?; true; end
end
