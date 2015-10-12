class ImageSearchController < ApplicationController
  before_filter :authenticate_user!

  def create
    query, per_page, page = params[:query], params[:per_page], params[:page]
    return skip_authorization && head(404) unless query

    image_searcher = ImageSearcher.new(query, per_page, page)
    authorize image_searcher
    render json: image_searcher.search, status: :ok
  end
end
