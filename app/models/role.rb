class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true
  
  scopify

  def self.publisher
    find_by name: 'publisher'
  end

  def self.pro
    find_by name: 'pro'
  end

end
