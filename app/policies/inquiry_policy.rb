class InquiryPolicy < ApplicationPolicy
  def require_user? ; false;  end
  def create?       ; true;   end
end