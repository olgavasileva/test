class Anonymous < Respondent

  def promote!(data={})
    User.transaction do
      self.update!(type: 'User')
      User.find(self.id).tap { |u| u.update(data) }
    end
  end

  def email
    "#{username}@anonymous.statisfy.co"
  end

  # Anonymous users don't have any special roles
  def has_role?
    false
  end

  def under_13?
    false
  end

  def age
    nil
  end

  def name
    username
  end

end
