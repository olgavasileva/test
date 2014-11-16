$ ->
  $(document).on 'click', 'label.choice-wrapper input[type=checkbox]',(e)->
    label = $(this).closest('label.choice-wrapper')
    parentForm = $(this).closest 'form'
    already_selected = parentForm.find('input[type="checkbox"]:checked')
    muex = label.data().muex != undefined

    if muex
      # uncheck all the others
      already_selected.not(this).prop('checked', false)

    else
      # only allow max_responses to be checked
      max_responses = label.closest('.form-group').data().maxResponses
      is_child_selected = label.find('input[type="checkbox"]:checked').length == 0
      muex_inputs = parentForm.find("label.choice-wrapper[data-muex] input[type=checkbox]:checked")
      muex_inputs.prop("checked", false)

      if already_selected.length > max_responses && !is_child_selected
        e.preventDefault()
        e.stopPropagation()

