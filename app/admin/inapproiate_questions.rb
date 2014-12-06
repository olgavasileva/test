ActiveAdmin.register Question, as: "InappropriateQuestion"  do
  menu parent: 'Questions'

  controller do
    def scoped_collection
      Question.joins :inappropriate_flags
    end
  end

  scope :all
  scope :active
  scope :suspended

  filter :user
  filter :title

  index do
    column :id
    column "Title" do |q|
      link_to q.title, question_sharing_path(q.uuid), target: :_blank
    end
    column "Created" do |q|
      "#{time_ago_in_words q.created_at} ago"
    end
    column :user
    column "Reports" do |q|
      link_to q.inappropriate_flags.count, admin_inappropriate_question_inappropriate_flags_path(q)
    end
    column "Feeds" do |q|
      link_to q.feed_items.count
    end
    column "State" do |q|
      q.state.titleize
    end
    column do |q|
      link_to 'Remove This Question', suspend_admin_inappropriate_question_path(q), method: :post unless q.suspended?
    end
  end

  member_action :suspend, method: :post do
    question = Question.find params[:id]
    question.suspend!
    redirect_to admin_inappropriate_questions_path, {notice: "Question Suspended!"}
  end


end