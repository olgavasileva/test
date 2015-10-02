$(document).ready ->
  getForm = ->
    form = $('form.edit_listicle')
    if form.length
      return form
    else
      return $('form.new_listicle')

  basicEditorActions = (->
    self = @
    @save = ->
      console.log 'saving listicle'
    @changeTab = ->
      self.save()
    @showLoading = ->
    @hideLoading = ->

    @)()
  advancedEditorActions = (->
    self = @
    @save = ->
      deferred = $.Deferred()
      console.log 'saving listicle'
      formData = getForm().serializeArray()
      $.ajax
        url: './'
        data: formData
        method: 'POST'
        success: (response)->
          deferred.resolve(response)
      deferred.promise()
    @changeTab = ->
      self.save().done ->
        $.ajax
          url: 'basic_form'
          success: (response)->
            $('#listicle-form').html response
            $('[rel=redactor]').redactor window.editorConfig

    @showLoading = ->
    @hideLoading = ->

    @)()
  $('#listicle-form-tab').click(basicEditorActions.changeTab)
  $('#advanced-listicle-form-tab').click(advancedEditorActions.changeTab)