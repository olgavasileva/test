require 'searchbing'
require 'open-uri'
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

    desc 'return image data in base64', {
      notes: <<-EOF
        input: current_user, image url
        output: image data in base64

        example:
        {image_data: 'image/png;base64,<base64_string>'}
      EOF
    }

    params do
      requires :auth_token, type: String
      requires :url, type: String
    end

    get '/image_data', http_codes: [
               [200, '400 - Invalid params'],
               [200, '402 - Invalid auth token'],
               [200, '403 - Login required']
           ] do
      validate_user!

      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Token'
      headers['Access-Control-Max-Age'] = '1728000'

      @data = 'data:image'
      open(params[:url]) do |io|
        if io.content_type =~ /image/
          @data += io.content_type[io.content_type.index('/')..-1]
          @data += ';base64,'
          @data += Base64.encode64(io.read)
        end
      end

      {image_data: @data}
    end
  end
end