$ ->
  $(document).on 'click', 'label.choice-wrapper',(e)->
    parentForm=$(this).closest 'form'
    already_selected=parentForm.find('input[type="checkbox"]:checked')
    is_child_selected=($(this).find('input[type="checkbox"]:checked').length>0)
    if(already_selected.length>=2 && !is_child_selected)
      e.preventDefault()
      e.stopPropagation()
