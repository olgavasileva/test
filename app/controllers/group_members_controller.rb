class GroupMembersController < ApplicationController
  def create
    if params[:group_id].present?
      group = Group.find(params.fetch(:group_id))
    elsif params[:group_name].present?
      group = Group.find_by_name(params.fetch(:group_name))
    end

    #if params[:group_password] != group.password
    #  flash[:alert] = "Incorrect group password."
    #  redirect_to :back
    #  return
    #end

    member = GroupMember.new(user_id: params.fetch(:user_id, current_user.id),
                             group_id: group.id)

    authorize member

    if member.save
      flash[:notice] = "Added user to group."
    else
      flash[:alert] = member.errors.full_messages.join('; ')
    end

    redirect_to :back
  end
end
