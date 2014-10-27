ActiveAdmin.register GalleryTemplate do
  config.sort_order = 'priority ASC'
  menu :label => "Galleries & Contests"


  controller do
    def resource_params
      return [] if request.get?
      [ params.require(:gallery_template).permit(:name, :description, :image, :rules, :contest,
                                                 :entries_open, :entries_close, :voting_open, :voting_close, :entries_open_date, :entries_open_time_hour,
                                                 :entries_open_time_minute, :entries_close_date, :entries_close_time_hour,
                                                 :entries_close_time_minute, :voting_open_date, :voting_open_time_hour,
                                                 :voting_open_time_minute, :voting_close_date, :voting_close_time_hour,
                                                 :voting_close_time_minute, :confirm_message, :recurrence, :max_votes, :num_occurrences,
                                                 :studio_id) ]
    end

    def new
      if params[:id].nil?
        @gallery_template = GalleryTemplate.new
      end
    end
  end

  index do
    column :name
    column :description
    column :contest
    column :priority
    column :recurrence
    default_actions
  end

  form do |f|
    f.inputs "General" do
      f.input :name
      f.input :description
      f.input :studio_id, as: :select, collection: Studio.all.order(:name)
      f.input :image, :as => :file
      f.input :entries_open, :as => :just_datetime_picker
      f.input :entries_close, :as => :just_datetime_picker
    end

    f.inputs "Contests" do
      f.input :contest
      f.input :voting_open, :as => :just_datetime_picker
      f.input :voting_close, :as => :just_datetime_picker
      f.input :recurrence, :as => :select, :collection => ['Daily', 'Weekly', 'Bi-Weekly']
      f.input :num_occurrences, label: 'Total Number of Contests'
      f.input :rules, :input_html => {:rows => 8}
      f.input :confirm_message, :input_html => {:rows => 5}
      f.input :max_votes, hint: "Max votes per IP address per day"
    end
    f.actions
  end
end
