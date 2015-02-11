ActiveAdmin.register Response, as: "Multiple Answers"  do
  menu parent: 'Questions'

  controller do
    def scoped_collection
      Response.joins(:question, :user)
        .where(questions: {allow_multiple_answers_from_user: false})
        .group(:question_id, :user_id)
        .having('count(*) > 1')
    end
  end

  batch_action :destroy, confirm: 'Are you sure you clear the selected responses?' do |ids|
    data = Response.where(id: ids).pluck(:question_id, :user_id).uniq
    t = Response.arel_table

    or_queries = data.map do |d|
      t[:question_id].eq(d[0]).and(t[:user_id].eq(d[1]))
    end.reduce { |q, v| q.or(v) }

    responses = Response.where.not(id: ids).where(or_queries)
    total = responses.count
    responses.destroy_all
    redirect_to collection_path, notice: "Destroyed #{total} responses"
  end

  index do
    selectable_column
    id_column
    column(:user) { |r| link_to(r.user.username, admin_user_path(r.user)) }
    column(:question) { |r| r.question.id }
    actions
  end
end
