require 'searchbing'
class TwoCents::ImageSearch < Grape::API
  resource :image_search do
    desc 'return images for the query using Bing search'

    params do
      requires :auth_token, type: String
      requires :search, type: String
      optional :per_page, type: Integer, default: 50
      optional :page, type: Integer, default: 1
    end

    get '/', http_codes: [
               [200, '400 - Invalid params'],
               [200, '402 - Invalid auth token'],
               [200, '403 - Login required']
           ] do
      validate_user!

      bing_searcher = Bing.new(BING_ACCOUNT_KEY, params[:per_page], 'Image')
      offset = (params[:page] - 1) * params[:per_page]
      images = bing_searcher.search(params[:search], offset).first[:Image]

      images.map { |image| image[:MediaUrl] }
    end
  end
end