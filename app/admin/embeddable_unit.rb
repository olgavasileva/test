ActiveAdmin.register EmbeddableUnit do
  menu parent: 'Surveys'

  permit_params :survey_id

  show do |eu|
    attributes_table do
      row :uuid
      row :survey
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
    end
    f.actions
  end
end