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

  def update
    group = Group.find(params[:id])

    authorize group

    if group.update_attributes(group_params)
      flash[:notice] = "Group was updated."
    else
      flash[:alert] = group.errors.full_messages.join('; ')
    end

    redirect_to :back
  end

  def destroy
    group = Group.find(params[:id])

    authorize group

    if group.destroy
      flash[:notice] = "Group \"#{group.name}\" was deleted."
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
