module CustomTrackable
  extend ActiveSupport::Concern

  def update_tracked_fields(request)
    old_current, new_current = self.current_sign_in_at, Time.now.utc
    self.last_sign_in_at     = old_current || new_current
    self.current_sign_in_at  = new_current

    remote_ip = if request.respond_to?(:remote_ip)
      request.remote_ip
    elsif defined?(ActionDispatch::Request)
      ActionDispatch::Request.new(request.env).remote_ip
    end

    old_current, new_current = self.current_sign_in_ip, remote_ip
    self.last_sign_in_ip     = old_current || new_current
    self.current_sign_in_ip  = new_current

    self.sign_in_count ||= 0
    self.sign_in_count += 1
  end

  def update_tracked_fields!(request)
    self.update_tracked_fields(request)
    self.save(validate: false)
  end
end
