class SegmentPolicy < ProPolicy
  class Scope < Scope
    def resolve
      @user.segments.order("created_at ASC")
    end
  end

  def index?   ; true;   end
  def create?  ; true;   end
  def update?  ; true;   end
  def destroy? ; true;   end
end