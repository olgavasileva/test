currentTab = 'basic'
class EditorActions
  constructor: ->
    @listicleForm = $('#listicle-form')
    @loadingEl = $('#loading-indicator').hide()
  getForm: ->
    form = $('form.edit_listicle')
    if form.length
      return form
    else
      return $('form.new_listicle')
  showLoading: ->
    @loadingEl.show()
  hideLoading: ->
    @loadingEl.hide()

class BasicEditorActions extends EditorActions
  save: ->
    console.log 'saving listicle basic'
    deferred = $.Deferred()
    setTimeout ->
      deferred.resolve()
      5000
    return deferred.promise()
  changeTab: ->
    return if currentTab == 'advanced'
    self = @
    @showLoading()
    @save().done ->
      $.ajax
        url: 'advanced_form'
        success: (response)->
          self.listicleForm.html response
          self.listicleForm.find('[rel=redactor]').redactor window.editorConfig
        complete: ->
          self.hideLoading()
          currentTab = 'advanced'

class AdvancedEditorActions extends EditorActions
  save: ->
    deferred = $.Deferred()
    console.log 'saving listicle advanced'
    formData = @getForm().serializeArray()
    $.ajax
      url: './'
      data: formData
      method: 'POST'
      success: (response)->
        deferred.resolve(response)
    deferred.promise()
  changeTab: ->
    return if currentTab == 'basic'
    self = @
    @showLoading()
    @save().done ->
      $.ajax
        url: 'basic_form'
        success: (response)->
          self.listicleForm.html response
          $('#listicle-form').find('[rel=redactor]').redactor window.editorConfig
        complete: ->
          self.hideLoading()
          currentTab = 'basic'

$(document).ready ->
  basicEditorActions = new BasicEditorActions()
  advancedEditorActions = new AdvancedEditorActions()
  $('#listicle-form-tab').click ->
    advancedEditorActions.changeTab()
  $('#advanced-listicle-form-tab').click ->
    basicEditorActions.changeTab()