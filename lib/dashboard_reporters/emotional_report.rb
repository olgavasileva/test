class EmotionalReport < DashboardReport
  private

  def get_report
    @report[:reach] = reach
    if tumblr_posts_urls.length > 0
      @report[:notes] = notes
      @report[:likes] = likes
      @report[:reblogs] = reblogs
      @report[:share_rate] = share_rate
    else
      @report.merge!({notes: 0, likes: 0, reblogs: 0, share_rate: 0})
    end
  end

  def reach
    @user.questions.sum(:view_count)
  end

  def notes
    tumblr_post_infos.map { |post_info| post_info['note_count'].to_i }.inject(:+).to_i
  end

  def likes
    notes_infos.map { |note| note['type'] == 'like' ? 1 : 0 }.inject(:+).to_i
  end

  def reblogs
    notes_infos.map { |note| note['type'] == 'reblog' ? 1 : 0 }.inject(:+).to_i
  end

  def notes_infos
    tumblr_post_infos.map { |post_info| post_info['notes'] }.flatten
  end

  def share_rate
    0 # not implemented
  end

  TUMBLR_REGEX = '^https?:\/\/.*\.tumblr\.com\/.*$'

  def tumblr_posts_urls
    @tumblr_posts_urls ||= Response.where(question_id: @question_ids)
                               .where('original_referrer REGEXP ?', TUMBLR_REGEX).pluck(:original_referrer).uniq
  end

  def tumblr_post_infos
    return @tumblr_post_infos if @tumblr_post_infos
    @tumblr_post_infos = []
    tumblr_url_regex = /(\w+).tumblr.com\/post\/(\d+)\/?.*/
    tumblr_posts_urls.each do |url|
      begin
        origin, post_id = url.match(tumblr_url_regex).captures
        response = tumblr_client.posts("#{origin}.tumblr.com", id: post_id, notes_info: true)
        post = response['posts'].first
        @tumblr_post_infos << post
      rescue
      end
    end

    @tumblr_post_infos
  end

end