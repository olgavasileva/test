class Gallery < ActiveRecord::Base
  has_many :gallery_elements
  belongs_to :gallery_template

  # Make a bunch of the template properties available directly from the gallery
  def name
    gallery_template.name unless gallery_template.nil?
  end

  def description
    gallery_template.description unless gallery_template.nil?
  end

  def image
    gallery_template.image unless gallery_template.nil?
  end

  def contest?
    gallery_template.contest? unless gallery_template.nil?
  end

  def contest
    return contest?
  end

  def recurrence
    gallery_template.recurrence unless gallery_template.nil?
  end

  def rules
    gallery_template.rules unless gallery_template.nil?
  end

  def confirm_message
    gallery_template.confirm_message unless gallery_template.nil?
  end

  def max_votes
    gallery_template.max_votes unless gallery_template.nil?
  end

  def studio_configuration
    gallery_template.studio_configuration
  end

  def entry_eligible?
    return contest? &&
        (entries_open.nil? || entries_open < Time.now) &&
        (entries_close.nil? || entries_close > Time.now)
  end

  def voting_eligible?
    return contest? &&
        (voting_open.nil? || voting_open < Time.now) &&
        (voting_close.nil? || voting_close > Time.now)
  end

  def total_entries
    GalleryElement.where("gallery_id = ?", id).count
  end

  def add_vote
    self.total_votes.nil? ? self.total_votes = 1 : self.total_votes += 1
    self.save
  end

  def num_winners
    gallery_template.num_winners unless gallery_template.nil?
  end

  def winners
    winners = []
    gallery_elements.order("votes DESC").limit(num_winners).each do |winner|
      winners << winner.api_response
    end
    winners
  end

  def self.contests_open_for_entries
    return Gallery.where("contest = true AND (entries_open is null OR entries_open < ?) AND (entries_close is null OR entries_close > ?)", Time.now, Time.now)
  end

  def self.my_gallery(user)
    gallery = Gallery.where('user_id' => user.id).take
    if gallery.nil?
      gallery = Gallery.new(:user_id => user.id)
      gallery.save!
    end
    return gallery
  end

  # Create a new contest based on this one.
  def recur_contest
    similar_contests = Gallery.where('gallery_template_id = ?', gallery_template.id).order("voting_close DESC")

    # If the template has already hit the maximum number of recurrences, don't recur
    return nil if (!gallery_template.num_occurrences.nil? && gallery_template.num_occurrences > 0 && similar_contests.size >= gallery_template.num_occurrences)

    # If this contest is not the latest contest for the gallery, we should not recur
    return nil if similar_contests.first.id != id

    new_contest = Gallery.new({:gallery_template => gallery_template})
    if recurrence.nil? || recurrence.blank?
      return
    end
    case recurrence
      when 'Daily'
        time_unit = 1.day
      when 'Weekly'
        time_unit = 1.week
      when 'Bi-Weekly'
        time_unit = 2.week
    end

    new_contest.entries_open = entries_open + time_unit unless entries_open.nil?
    new_contest.entries_close = entries_close + time_unit unless entries_close.nil?
    new_contest.voting_open = voting_open + time_unit unless voting_open.nil?
    new_contest.voting_close = voting_close + time_unit unless voting_close.nil?
    new_contest.save
    return new_contest
  end

  def get_gallery_elements(scope="current", sort_order, page, limit)
    items = []
    gallery_elements = []
    if scope == "all"
      gallery_ids = []
      Gallery.where("gallery_template_id = ?", gallery_template_id).each do |g|
        gallery_ids << g.id
      end
      gallery_elements = GalleryElement.where(gallery_id: gallery_ids).order(sort_order).page(page).per(limit)
      count = GalleryElement.where(gallery_id: gallery_ids).size
    else
      gallery_elements = GalleryElement.where(gallery_id: id).order(sort_order).page(page).per(limit)
      count = gallery_elements.count
    end
    gallery_elements.each do |element|
      items << element.api_response
    end
    {:items => items, :count => count}
  end

  def self.get_active_public_galleries
    # Make sure all recurring contests have an active instance
    GalleryTemplate.assure_recurring_contests
    galleries = Gallery.where("(((entries_open is null OR entries_open < ?) AND " +
                                  "(entries_close is null OR entries_close > ?)) OR " +
                                  "(voting_open is null OR voting_open < ?)) AND " +
                                  "(voting_close is null OR voting_close > ?) AND " +
                                  "user_id is null", Time.now, Time.now, Time.now, Time.now).all
    galleries_to_remove = []
    galleries.each do |gallery|
      if gallery.gallery_template.nil?
        galleries_to_remove << gallery
      end
    end

    return galleries - galleries_to_remove
  end

  def self.get_previous_contests(limit)
    return Gallery.where("voting_close < ?", Time.now).order("voting_close DESC").limit(limit)
  end

  def api_response
    {:id => id, :entries_open => entries_open, :entries_close => entries_close, :voting_open => voting_open,
     :voting_close => voting_close, :total_votes => total_votes, :total_entries => total_entries, :name => name,
     :description => description, :contest => contest, :image => image.url, :rules => rules}
  end
end
