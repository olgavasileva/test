class SegmentPolicy < ProPolicy
  class Scope < Scope
    def resolve
      @user.segments.order("created_at ASC")
    end
  end

  def owns_segment?
    @user == @record.user
  end

  def index?           ; owns_segment?;   end
  def create?          ; owns_segment?;   end
  def update?          ; owns_segment?;   end
  def destroy?         ; owns_segment?;   end
  def question_search? ; owns_segment?;   end
end