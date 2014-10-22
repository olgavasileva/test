class CommunityMembersController < ApplicationController
  def create
    community = Group.find(params.fetch(:community_id))
    member = CommunityMember.new(user_id: params.fetch(:user_id),
                                 community_id: community.id)

    authorize member

    if member.save
      flash[:notice] = "Added user to community."
    else
      flash[:alert] = member.errors.full_messages.join('; ')
    end

    redirect_to :back
  end

  def destroy
    member = CommunityMember.where(params.slice(:user_id, :community_id)).first

    authorize member

    if member.destroy
      flash[:notice] = "Removed user from community."
    else
      flash[:alert] = member.errors.full_messages.join('; ')
    end

    redirect_to :back
  end
end
