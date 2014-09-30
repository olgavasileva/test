class GroupMembersController < ApplicationController
  def create
    member = GroupMember.new(user_id: params.fetch(:user_id),
                             group_id: params.fetch(:group_id))

    authorize member

    if member.save
      flash[:notice] = "Added user to group."
    else
      flash[:alert] = member.errors.full_messages.join('; ')
    end

    redirect_to :back
  end
end
