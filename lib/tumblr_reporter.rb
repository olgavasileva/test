require 'nokogiri'
require 'open-uri'
class TumblrReporter

  attr_reader :errors

  BLOG_NAME = 'gostatisfy.tumblr.com'.freeze
  Z = 2.706025
  CONFIDENCE_LEVEL = 90

  IFRAME_REGEX = /qp\/([\w]+)\/?/i

  def initialize(post_id)
    @errors = []
    @post_id = post_id
  end

  def report
    report = {}
    begin
      Timeout::timeout(30) do
        @post = TumblrReporter.client.posts('gostatisfy.tumblr.com',
                                            :id => @post_id,
                                            :notes_info => 1)['posts'].to_a.first
        report.merge!({
                          title: post['title'],
                          url: post_url,
                          id: @post_id,
                          confidence_rercentage: CONFIDENCE_LEVEL
                      })
        report[:estimated] = estimated
        report[:confidence_level] = confidence_level.round(2)
        report[:note_count] = note_count
        report[:surveys] = search_surveys
      end
    rescue Timeout::Error
      @errors.push "Sorry, but we cannot provide information for post: #{@post_id} because of timeout"
    rescue Exception => e
      @errors.push e.message
    end
    report.merge!({errors: @errors})
  end

  private

  def self.client
    @client ||= Tumblr::Client.new(TUMBLER_KEYS)
  end

  def estimated
    @this_post_like_count = 0
    @this_post_reblog_count = 0
    post['notes'].each do |note_info|
      if note_info['type'] == 'reblog'
        @this_post_reblog_count += 1
      elsif note_info['type'] == 'like'
        @this_post_like_count += 1
      end
    end

    note_count = post['note_count']

    estimated = {likes: 0, reblogs: 0}

    if post['note_count'] > ss
      notesby50 = note_count.to_f/ss.to_f
      est_likes = @this_post_like_count.to_f * notesby50.to_f
      est_reblogs = @this_post_reblog_count.to_f * notesby50.to_f
      estimated[:likes] = est_likes.round
      estimated[:reblogs] = est_reblogs.round
    else
      estimated[:likes] = @this_post_like_count
      estimated[:reblogs] = @this_post_reblog_count
    end

    estimated
  end

  def post
    @post
  end

  def ss
    @this_post_like_count + @this_post_reblog_count
  end

  def note_count
    [@post['note_count'].to_i, ss].max
  end

  def post_url
    post['post_url']
  end

  def confidence_level
    pf = (note_count.to_f - ss.to_f) / (note_count - 1)
    p = @this_post_like_count.to_f/ss
    q = 1 - p
    Math.sqrt(Z * p * q / ss * pf) * 100
  end

  def search_surveys
    surveys = []
    begin
      Nokogiri.HTML(open(post_url)).css('iframe').each do |iframe|
        match = iframe[:src].match(IFRAME_REGEX)
        if match && match[1]
          uuid = match[1]
          survey = Survey.find_by uuid: uuid
          surveys.push id: survey.id, uuid: uuid if survey
        end
      end
    rescue OpenURI::HTTPError => e
      @errors.push "Cannot open post url: #{post_url} (#{e.message})"
    end
    surveys
  end

end