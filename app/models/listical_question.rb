class ListicalQuestion < ActiveRecord::Base

  validates_presence_of :body, :title

  belongs_to :listical, class_name: 'Listical'

  delegate :user, to: :listical, allow_nil: false

end
