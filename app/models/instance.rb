class Instance < ActiveRecord::Base
  belongs_to :device
  belongs_to :user, class_name:"Respondent"

  default push_app_name: 'Statisfy'

  before_validation(on: :create) { ensure_uuid }

  validates :device, presence: true
  validates :push_environment, inclusion: { in: %w(production development), allow_nil: true }

  def refresh_auth_token
    self.auth_token = 'A' + UUID.new.generate
  end

  # options[:expiry] is the time in seconds Apple will spend trying to deliver the notification to the device. The notification is discarded if it has not been delivered in this time. Default is 1 day.
  # options[:deliver_after] may be set if you'd like to delay delivery of the notification to a specific time in the future - e.g. 1.hour.from_now
  def push options = {}
    options = options.reverse_merge badge:nil, sound:nil, alert:nil, custom_properties:nil

    if push_token.present?
      if device.ios?
        n = Rpush::Apns::Notification.new
        n.app = Rpush::Apns::App.find_by name:push_app_name, environment:push_environment
        n.device_token = push_token
        n.alert = options[:alert]
        n.badge = options[:badge]
        n.sound = case
          when options[:sound].class == String
            options[:sound]
          when options[:sound]
            "1.aiff"
          else
            nil
          end
        n.expiry = options[:expiry] if options[:expiry]
        n.attributes_for_device = options[:custom_properties] if options[:custom_properties]
        n.deliver_after = options[:deliver_after] if options[:deliver_after]
        n.save
      elsif device.android?
        n = Rapns::Gcm::Notification.new
        n.app = Rpush::Gcm::App.find_by name:push_app_name, environment:push_environment
        n.registration_ids = [push_token]
        n.data = options
        n.save
      else
        logger.info("#{Time.current} Could not send notification - unknown or missing platform: #{device.platform}")
        false
      end
    else
      false
    end
  end

  def self.create_null_instance(user)
    create! device: Device.new, user: user
  end

  private
    def ensure_uuid
      self.uuid ||= "I"+UUID.new.generate
    end

end
