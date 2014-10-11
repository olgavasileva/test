class GroupsController < ApplicationController
  def create
    group = Group.new({ user: current_user }.merge(group_params))

    authorize group

    if group.save
      flash[:notice] = "Group \"#{group.name}\" was created."
    else
      flash[:alert] = group.errors.full_messages.join('; ')
    end

    redirect_to :back
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end
end
