ActiveAdmin.register Question do
  menu parent: 'Questions'

  permit_params :id, :position, :category_id, :title, :state, :special, :trending_multiplier, :disable_question_controls, :created_at

  controller do
    def scoped_collection
      end_of_association_chain.includes(:trend)
    end
  end

  filter :user_username, as: :string, label: "Asker's Username"
  filter :title
  filter :id
  filter :uuid
  filter :type
  filter :category
  filter :state, as: :check_boxes, collection: Question::STATES
  filter :kind, as: :check_boxes, collection: Question::KINDS
  filter :allow_multiple_answers_from_user

  member_action :set_created_at_to_now do
    q = Question.find params[:id]
    q.created_at = Time.current
    q.save!
    flash[:notice] = "Updated created_at to now"
    redirect_to action: :index
  end

  index do
    selectable_column
    column :id
    column :title
    column "Choices" do |q|
      case q.type
      when 'MultipleChoiceQuestion'
        link_to pluralize(q.choices.count, "choice"), admin_multiple_choice_question_multiple_choices_path(q)
      when 'TextChoiceQuestion'
        link_to pluralize(q.choices.count, "choice"), admin_text_choice_question_text_choices_path(q)
      when 'OrderQuestion'
        link_to pluralize(q.choices.count, "choice"), admin_order_question_order_choices_path(q)
      when 'YesNoQuestion'
        link_to pluralize(q.choices.count, "choice"), admin_yes_no_question_yes_no_choices_path(q)
      when 'ImageChoiceQuestion'
        link_to pluralize(q.choices.count, "choice"), admin_image_choice_question_image_choices_path(q)
      end
    end
    column :type
    column :category
    column "Asked By", sortable: 'users.username' do |q|
      q.user.username
    end
    column "Resp" do |q|
      q.responses.count
    end
    column "Cmts" do |q|
      q.comments.count
    end
    column :state
    column :kind
    column :special
    column :require_comment
    column "TI", sortable: 'trends.rate' do |q|
      q.trend_rate
    end
    column "T*", sortable: :trending_multiplier do |q|
      q.trending_multiplier
    end
    column :created_at
    column do |q|
      link_to "Update Created At to Now", set_created_at_to_now_admin_question_path(q)
    end
    actions
  end

  show do |question|
    columns do
      column do
        attributes_table do
          row :id
          row :question
          row(:type) { status_tag(question.type) }
          row :title
          row :rotate
          row :position
          row :created_at
          row :updated_at
        end

        panel 'Background Image' do
          image = question.background_image
          content  = image_tag image.image.url, class: 'panel-image'
          content += link_to('View', admin_background_image_path(image))
          content += ' / '
          content += link_to('Edit', edit_admin_background_image_path(image))
        end if question.background_image.present?
      end

      column do
        panel 'Question Choices' do
          table_for question.choices do
            column :id
            column :title
            column(:actions) { |c| link_to('View', admin_choice_path(c)) }
          end
        end
      end if question.choices.size > 0
    end
  end

  form do |f|
    f.inputs f.object.type do
      f.input :state, collection: Question::STATES, include_blank: false
      f.input :category
      f.input :title
      f.input :special
      f.input :require_comment
      f.input :trending_multiplier
      f.input :disable_question_controls
      f.input :allow_multiple_answers_from_user
      f.input :created_at
    end
    f.actions
  end

end
