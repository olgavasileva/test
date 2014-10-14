class CommunitiesController < ApplicationController
  def create
    community = Community.new({ user: current_user }.merge(community_params))

    authorize community

    if community.save
      flash[:notice] = "Community \"#{community.name}\" was created."
    else
      flash[:alert] = community.errors.full_messages.join('; ')
    end

    redirect_to :back
  end

  private

  def community_params
    params.require(:community).permit(:name, :description, :private, :password)
  end
end
