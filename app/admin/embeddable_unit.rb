ActiveAdmin.register EmbeddableUnit do
  menu parent: 'Surveys'

  permit_params :survey_id, :width, :height, :thank_you_markdown

  index do
    column :id
    column :survey
    column "Script" do |eu|
        script = <<-END
<script type="text/javascript"><!--
  statisfy_unit = "#{eu.uuid}";
  statisfy_unit_width = #{eu.width}; statisfy_unit_height = #{eu.height};
//-->
</script>
<script type="text/javascript" src="#{request.base_url}/#{Rails.env}/show_unit.js">
</script>
        END
        "<pre><code>#{ERB::Util.html_escape script}</code></pre>".html_safe
    end
    actions
  end


  show do |eu|
    attributes_table do
      row :uuid
      row :survey
      row :width
      row :height
      row :thank_you_html do
        eu.thank_you_html.html_safe
      end
      row "Embed Script" do
        script = <<-END
<script type="text/javascript"><!--
  statisfy_unit = "#{eu.uuid}";
  statisfy_unit_width = #{eu.width}; statisfy_unit_height = #{eu.height};
//-->
</script>
<script type="text/javascript" src="#{request.base_url}/#{Rails.env}/show_unit.js">
</script>
        END
        "<pre><code>#{ERB::Util.html_escape script}</code></pre>".html_safe
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :survey
      f.input :width
      f.input :height
      f.input :thank_you_markdown, label: "Thank you page", hint: "You can use markdown to style this text"
    end
    f.actions
  end
end