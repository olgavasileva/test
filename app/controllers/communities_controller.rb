class CommunitiesController < ApplicationController
  skip_after_action :verify_authorized, only: [:join]

  def join
    # Redirect to the web app's community page
    path = "#/app/profile//communities/join"
    path += "?community_id=#{params[:community_id]}" if params[:community_id]
    redirect_to File.join(ENV['WEB_APP_URL'], path)
  end

  def create
    community = Community.new({ user: current_user }.merge(community_params))

    authorize community

    if community.save
      flash[:notice] = "Community \"#{community.name}\" was created."
    else
      flash[:alert] = community.errors.full_messages.join('; ')
    end

    redirect_to invite_community_path(community)
  end

  def destroy
    community = Community.find(params[:id])

    authorize community

    if community.destroy
      flash[:notice] = "Community \"#{community.name}\" was deleted."
    else
      flash[:alert] = community.errors.full_messages.join('; ')
    end

    redirect_to :back
  end

  def invite
    @community = Community.find(params.fetch(:id))

    authorize @community
  end

  private

  def community_params
    params.require(:community).permit(:name, :description, :private, :password)
  end
end
