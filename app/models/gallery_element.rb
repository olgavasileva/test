class GalleryElement < ActiveRecord::Base
  delegate :url_helpers, to: 'Rails.application.routes'

  belongs_to :gallery
  belongs_to :scene
  belongs_to :user
  has_many :gallery_element_votes, dependent: :destroy

  after_initialize do
    if self.new_record?
      self.votes = 0
    end
  end

  def add_vote(user_id=nil)
    vote = gallery_element_votes.voted(user_id).first
    incr = false

    if vote.nil?
      gallery_element_votes.create(user_id: user_id, votes: 1)
      incr = true
    elsif vote && vote.votes < gallery.max_votes
      vote.update_attribute(:votes, vote.votes + 1)
      incr = true
    end

    if incr
      self.votes += 1
      self.save
      self.gallery.add_vote
    end

    self.votes
  end

  def self.add(contest, scene)
    element = GalleryElement.new({:gallery => contest, :scene => scene, :user => scene.user})
    element.save
    return element
  end

  def voted?(ip=nil)
    vote = gallery_element_votes.voted(ip).first
    #return false if vote.nil?

    (vote.votes >= gallery.max_votes rescue false)
  end

  def api_response
    {'id' => self.id, 'scene_id' => self.scene.id, 'image_url' => self.scene.image_url,
     'image_thumb_url' => self.scene.image.thumb.url, 'votes_count' => self.votes,
     'entry_date' => self.created_at.strftime('%Y-%m-%d %I:%M:%S'), 'votable' => self.gallery.voting_eligible?}
  end

  def share_link(type, share_user = nil)
    if gallery.contest?
      url = url_helpers.contest_show_entry_url(:id => gallery.id, :entry_id => id, :host => APP_CONFIG[:site_url])
    else
      url = scene.share_link('link', user)
    end
    uid = (share_user ? share_user.id : 0)
    # Temporarily don't add tracking info to text messages because it makes the URL too long and splits it into 2 messages.
    return (url + "?referral=#{uid}") if type == 'txt'
    studio_name = scene.studio_configuration.name.gsub(" ", "_")
    return url + "?f=share_#{type}_#{studio_name}_scene&utm_source=share&utm_medium=#{type}_share&utm_campaign=#{studio_name}&utm_content=scene&referral=#{uid}"
  end

  def delete(user)
    # If the user is deleting from their personal gallery, remove from all contests as well
    if (gallery.user_id == user.id)
        scene.gallery_elements.each do |gallery_element|
          gallery_element.destroy
        end
        scene.set_deleted
        scene.save!
    end
  end

end
