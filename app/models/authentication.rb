class Authentication < ActiveRecord::Base

  PROVIDERS = %w{facebook}.freeze

  belongs_to :user

  validates_presence_of :provider, :uid, :token
  validates :provider, inclusion: {in: PROVIDERS}
  validates_uniqueness_of :uid, scope: [:provider]

  def self.from_provider_id(provider, id)
    params = {provider: provider, uid: id}
    self.where(params).first_or_initialize
  end

  def self.from_social_profile(profile, user=nil)
    self.from_provider_id(profile.provider, profile.uid).tap do |auth|
      auth.token = profile.token
      auth.user = user if user
    end
  end
end
