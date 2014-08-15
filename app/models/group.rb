class Group < ActiveRecord::Base
  belongs_to :user
  has_many :members, class_name:"GroupMember", dependent: :destroy
end
