module ApplicationHelper

	# Returns the full title on a per-page basis.
	def full_title(page_title)
	    base_title = ENV['app_name']
	    if page_title.empty?
	      base_title
	    else
	      "#{base_title} | #{page_title}"
	    end
	end

  # Returns a hisrc-ready html image tag for the +src+.
  # If not otherwise specified, it will add two data attributes
  # which are required for hisrc to work.
  #
  # ==== Options
  # +responsive_image_tag+ accepts the same options as +image_tag+,
  # and two additional options as well:
  #
  # * <tt>:'1x'</tt> - If no 1x option is provided, the +src+ is used.
  # * <tt>:'2x'</tt> - If no 2x option is provided, "@2x" is inserted into
  # the +src+. So "rails.png" becomes "rails@2x.png".
  #
  # ==== Examples
  #  responsive_image_tag("rails.png") # =>
  #    <img src="/assets/rails.png" data-1x="/assets/rails.png" data-2x="/assets/rails@2x.png" />
  #  responsive_image_tag("http://placehold.it/100x100", :'1x' => "http://placehold.it/200x200", :'2x' => "http://placehold.it/400x400") # =>
  #    <img src="http://placehold.it/100x100" data-1x="http://placehold.it/200x200" data-2x="http://placehold.it/200x200" />
  def responsive_image_tag(src, options = {})
    options[:data] ||= {}
    options[:data][:'1x'] ||= path_to_image(options.delete(:'1x').presence || options.delete('1x').presence || src)
    options[:data][:'2x'] ||= path_to_image(options.delete(:'2x').presence || options.delete('2x').presence || src.gsub(/([\w\/]+)\.(\w+)$/, '\1@2x.\2'))

    image_tag(src, options)
  end

  def get_the_app_path
    "https://itunes.apple.com/us/app/statisfy/id918625793?mt=8"
  end
end
