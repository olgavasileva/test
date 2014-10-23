$ ->
  $(document).on 'click', 'label .choice-wrapper',(e)->
    parentForm=$(this).closest 'form'
    already_selected=parentForm.find('input[type="checkbox"]:checked')
    if(already_selected.lenght>=2)
      e.preventDefault()
      e.stopPropagation()
