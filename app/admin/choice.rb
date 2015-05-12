ActiveAdmin.register Choice do
  menu false

  actions :show

  show do |choice|
    columns do
      column do
        attributes_table do
          row :id
          row :title
          row(:question) { link_to(choice.question.title, admin_question_path(choice.question)) }
          row(:type) { status_tag(choice.type, :ok) }
          row(:rotate) { status_tag(choice.rotate, choice.rotate? ? :ok : :error) }
          row :position if choice.position
          row :created_at
        end
      end

      if choice.background_image.present?
        column do
          panel 'Background Image' do
            img = choice.background_image
            content  = image_tag img.web_image_url, style: 'margin: 0px auto 10px; max-width: 100%; display: block;'
            content += link_to('View', admin_background_image_path(img))
            content += ' / '
            content += link_to('Edit', edit_admin_background_image_path(img))
          end
        end
      end
    end
  end
end
