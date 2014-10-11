class UserFollowed < Message

  belongs_to :follower, class_name: "User"

  def body
    follower = User.find self.follower_id
    "#{follower.username} followed you"
  end

end
