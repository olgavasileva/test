class GroupTarget < ActiveRecord::Base
  belongs_to :question
  belongs_to :group

  validates :question, presence: true
  validates :group, presence: true

  validate :group_belongs_to_question_user

  private

  def group_belongs_to_question_user
    if group.user != question.user
      errors.add("must have group belonging to question user")
    end
  end
end
