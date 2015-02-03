class Authentication < ActiveRecord::Base

  PROVIDERS = %w{facebook}.freeze

  belongs_to :user

  validates_presence_of :provider, :uid, :token
  validates :provider, inclusion: {in: PROVIDERS}
  validates_uniqueness_of :uid, scope: [:provider]
end
