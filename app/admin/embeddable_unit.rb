ActiveAdmin.register EmbeddableUnit do
  menu parent: 'Surveys'

  permit_params :survey_id, :thank_you_markdown

  index do
    column :id
    column :survey
    column "Script" do |eu|
      "<label>Script</label><div><textarea rows='7' style='width: 100%' onmouseenter='$(this).select()'>#{eu.script request}</textarea></div>".html_safe +
      "<label>iFrame</label><div><input style='width: 100%' onmouseenter='$(this).select()' value='#{eu.iframe request}'></div>".html_safe
    end
    actions
  end


  show do |eu|
    attributes_table do
      row :uuid
      row :survey
      row :thank_you_html do
        eu.thank_you_html.html_safe
      end
      row "Script" do
        "<label>Script</label><div><textarea rows='7' style='width: 100%' onmouseenter='$(this).select()'>#{eu.script request}</textarea></div>".html_safe +
        "<label>iFrame</label><div><input style='width: 100%' onmouseenter='$(this).select()' value='#{eu.iframe request}'></div>".html_safe
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :survey
      f.input :thank_you_markdown, label: "Thank you page", hint: "You can use markdown to style this text"
    end
    f.actions
  end
end
