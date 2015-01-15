class UserFollowed < Message

  belongs_to :follower, class_name: "Respondent"

  def body
    follower = Respondent.find self.follower_id
    "#{follower.username} followed you"
  end

end
