ActiveAdmin.register TumblrReporter do
  config.comments = false
  config.clear_action_items!
  before_filter do @skip_sidebar = true end

  controller do
    def index
      @report = TumblrReporter.new(params[:post_id]).report if params[:post_id]
      render 'admin/tumblr_reporter/show', :layout => 'active_admin'
    end
  end
end
