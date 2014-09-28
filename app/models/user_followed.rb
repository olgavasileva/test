class UserFollowed < Message 

  def body
    follower = User.find self.follower_id
    "#{follower.username} followed you"
  end

end
