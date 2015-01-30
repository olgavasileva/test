ActiveAdmin.register Comment do

  config.per_page = 100
  config.clear_action_items!

  controller do
    def scoped_collection
      Comment.includes(:likes)
    end
  end

  collection_action :delete_all_query, method: :delete do
    if params['q'].present?
      comments = Comment.ransack(params['q']).result
      total = comments.count
      comments.destroy_all
      redirect_to collection_path, notice: "Destroyed #{total} records"
    else
      redirect_to collection_path, warning: "Nothing to delete"
    end
  end

  action_item(only: :index, if: proc { params[:q].present? }) do
    path = delete_all_query_admin_comments_path(q: params[:q])
    confirm = 'Are you sure you want to delete ALL comments matching this query?'
    confirm += ' This could take a really long time and CANNOT BE UNDONE.'
    link_to 'Delete All Matching Query', path, {
      class: 'danger',
      method: :delete,
      data: {confirm: confirm}
    }
  end

  batch_action :destroy, confirm: 'Are you sure you want to delete the selected comments?' do |ids|
    Comment.where(id: ids).destroy_all
    redirect_to collection_path, notice: "Destroyed #{ids.length} records"
  end

  filter :user
  filter :body
  filter :created_at

  index do
    selectable_column
    id_column
    column :comment_type
    column :body
    column "Likes" do |comment|
      comment.likes.size
    end
    column :created_at
    actions
  end
end
