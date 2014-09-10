class GalleryTemplate < ActiveRecord::Base
  mount_uploader :image, ImageUploader
  validates :max_votes, numericality: {greater_than: 0}, presence: true
  just_define_datetime_picker :entries_open
  just_define_datetime_picker :entries_close
  just_define_datetime_picker :voting_open
  just_define_datetime_picker :voting_close
  belongs_to :studio

  # When the dates for a template for a recurring contest are changed, we need to modify the current instance
  # of that contest.  If the dates have been moved out beyond the current contest dates, we use those dates.
  # We don't want to move the dates back to a time that was previously set, so if the dates are before the
  # dates in the current instance, we just adjust the time of day to reflect any changes.
  def adjust_contest_time(source_datetime, target_datetime)
    if target_datetime.nil? || source_datetime > target_datetime
      return source_datetime
    else
      return target_datetime.change(hour: source_datetime.to_datetime.hour, minute: source_datetime.to_datetime.minute)
    end
  end

  # When a gallery template is saved:
  # - If there are no instances of this template, we create one
  # - If there is one instance of this template, we modify it
  # - If there are multiple instances of this template, it is an active recurring contest.
  #      We adjust the entry/voting times of the currently-running contest to reflect the changes.
  after_save do
    # Create an initial gallery instance based on the template
    galleries = Gallery.where('gallery_template_id = ?', id).order("voting_close DESC")
    if galleries.size > 1
      gallery = galleries.take
      gallery.entries_open = adjust_contest_time(entries_open, gallery.entries_open)
      gallery.entries_close = adjust_contest_time(entries_close, gallery.entries_close)
      gallery.voting_open = adjust_contest_time(voting_open, gallery.voting_open)
      gallery.voting_close = adjust_contest_time(voting_close, gallery.voting_close)
      gallery.save
      return
    end

    if galleries.size == 1
      gallery = galleries.take
    else
      gallery = Gallery.new({:gallery_template_id => id})
    end
    gallery.entries_open = entries_open
    gallery.entries_close = entries_close
    gallery.voting_open = voting_open
    gallery.voting_close = voting_close
    gallery.save
  end

  def get_contest_open_for_entries
    gallery = Gallery.where('gallery_template_id = ?', id).order("entries_close DESC").first
    while !gallery.nil? && !gallery.entries_close.nil? && gallery.entries_close < Time.now && !gallery.recurrence.nil? && !gallery.recurrence.blank?
      gallery = gallery.recur_contest
    end
    return gallery
  end

  def get_contest_open_for_voting
    gallery = Gallery.where('gallery_template_id = ? AND (voting_open is null OR voting_open < ?)', id, Time.now).order("voting_close DESC").first
    if gallery.nil?
      # Not open for voting yet, remove that restriction
      gallery = Gallery.where('gallery_template_id = ?', id).order("voting_close DESC").first
    end
    while !gallery.nil? && !gallery.voting_close.nil? && gallery.voting_close < Time.now && !gallery.recurrence.nil? && !gallery.recurrence.blank?
      gallery = gallery.recur_contest
    end
    # If the contest didn't recur, and the current instance is already closed for entries, return nil
    if gallery.nil? || gallery.entries_close.nil? || gallery.entries_close < Time.now
      return nil
    end
    return gallery
  end

  # Get the top vote-getters from recent contests based on this template
  # num_contests - The number of contests to get winners from
  def winners(num_contests)
    contests = Gallery.where('gallery_template_id = ? AND voting_close < ?', id, Time.now).order("voting_close DESC").limit(num_contests)
    results = []
    contests.each do |contest|
      winners = contest.winners
      results << {'contest' => contest, 'winners' => winners}
    end

    return results
  end

  # Make sure all recurring contests have an active instance
  def self.assure_recurring_contests
    recurring_contests = self.where('recurrence is not null')
    return if recurring_contests.empty?
    recurring_contests.each do |contest|
      # This will cause the contest to recur if there's nothing open for voting
      contest.get_contest_open_for_voting
    end
  end

end
