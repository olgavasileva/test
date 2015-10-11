class ImageSearcher

  PER_PAGE = 20

  def initialize(query, per_page = PER_PAGE, page = 1)
    @query = query
    @per_page = per_page ? per_page.to_i : PER_PAGE
    @page = page ? page.to_i : 1
  end

  def search
    bing_searcher = Bing.new(BING_ACCOUNT_KEY, @per_page, 'Image')
    offset = (@page - 1) * @per_page
    images = bing_searcher.search(@query, offset).first[:Image]

    images.map { |image| {media_url: image[:MediaUrl], thumbnail: image[:Thumbnail][:MediaUrl]} }
  end
end