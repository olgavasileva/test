class Answer < ActiveRecord::Base
	belongs_to :user
	belongs_to :question
	has_many :responses, dependent: :destroy

	validates :user_id, presence: true
	validates :question_id, presence: true
	validates_uniqueness_of :user_id, :scope => :question_id

	def self.dedupe
    # find all models and group them on keys which should be common
    grouped = all.group_by{|answer| [answer.user_id, answer.question_id] }
    grouped.values.each do |duplicates|
      # the first one we want to keep right?
      first_one = duplicates.shift # or pop for last one
      # if there are any more left, they are duplicates
      # so delete all of them
      duplicates.each{|double| double.destroy} # duplicates can now be destroyed
    end
  end

	def as_json(options={})
		super(:include => [:responses, :question => {:include => [:category, :choices, :user => {:only => [:id, :username, :name]}], :only => [:id, :created_at, :title, :info, :image_url, :question_type, ]}, :user => {:only => [:id, :username, :name]}], :only => [:id, :created_at, :agree])
	end

end
