class ProxyController < ApplicationController
  skip_filter :authenticate_user!
  skip_filter :verify_authorized

  def url
    url = params[:url]
    uri = URI(url)

    valid_hosts = []
    valid_hosts << "#{ENV['AWS_BUCKET']}.s3.amazonaws.com"
    valid_hosts << URI(ENV['AWS_ASSET_HOST']).host if ENV['AWS_ASSET_HOST'].present?

    if valid_hosts.include? uri.host
      render text: (url.present? && open(url).read)
    else
      render text: "404 Not Found", status: :not_found
    end
  end
end