class Instance < ActiveRecord::Base
  belongs_to :device
  belongs_to :user

  before_validation(on: :create) { ensure_uuid }


  private
    def ensure_uuid
      self.uuid ||= "I"+UUID.new.generate
    end

end
