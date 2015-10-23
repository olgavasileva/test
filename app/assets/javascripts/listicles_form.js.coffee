currentTab = 'basic'

getListicleId = -> $('input[name="listicle_id"]').val()
setListicleId = ->
  listicleId = getListicleId()

class EditorActions
  constructor: ->
    @listicleForm = $('#listicle-form')
    @advancedListicleForm = $('#advanced-listicle-form')
    @loadingEl = $('#loading-indicator').hide()
#  getForm: ->
#    $('form')
#    form = $('form.edit_listicle')
#    if form.length
#      return form
#    else
#      return $('form.new_listicle')
  showLoading: ->
    @loadingEl.show()
  hideLoading: ->
    @loadingEl.hide()

class BasicEditorActions extends EditorActions
  getForm: ->
    @listicleForm.find('form')
  save: ->
    listicleId = getListicleId()
    formData = @getForm().serializeArray()
#    url = if listicleId then "./#{listicleId}/" else './'
    method = if listicleId then 'PATCH' else 'POST'

    console.log 'saving listicle basic'
    $.ajax
      url: './'
      data: formData
      method: method
      dataType: 'json'
  changeTab: ->
    return if currentTab == 'advanced'
    self = @
    @showLoading()
    @save().then((response)->
      self.advancedListicleForm.html response.form
      self.advancedListicleForm.find('[rel=redactor]').redactor window.editorConfig
      setListicleId()
      currentTab = 'advanced'
    ).always -> self.hideLoading()
#      $.ajax
#        url: "#{getListicleId()}/advanced_form"
#        method: 'GET'
#        success: (response)->
#          self.listicleForm.html response
#          self.listicleForm.find('[rel=redactor]').redactor window.editorConfig
#        complete: ->
#          setListicleId()
#          self.hideLoading()
#          currentTab = 'advanced'

class AdvancedEditorActions extends EditorActions
  getForm: ->
    @advancedListicleForm.find('form')
  save: ->
    listicleId = getListicleId()
    console.log 'saving listicle advanced'
    formData = @getForm().serializeArray()
    $.ajax
      url: "./advanced_form"
      data: formData
      method: 'PATCH'
      dataType: 'json'
  changeTab: ->
    return if currentTab == 'basic'
    self = @
    @showLoading()
    @save().done((response)->
      self.listicleForm.html response.form
      self.listicleForm.find('[rel=redactor]').redactor window.editorConfig
      setListicleId()
      currentTab = 'basic'
    ).always -> self.hideLoading()
#      $.ajax
#        url: getListicleId() + '/basic_form'
#        success: (response)->
#          self.listicleForm.html response
#          $('#listicle-form').find('[rel=redactor]').redactor window.editorConfig
#        complete: ->
#          self.hideLoading()
#          setListicleId()
#          currentTab = 'basic'

$(document).ready ->
  basicEditorActions = new BasicEditorActions()
  advancedEditorActions = new AdvancedEditorActions()
  $('#listicle-form-tab').click ->
    advancedEditorActions.changeTab()
  $('#advanced-listicle-form-tab').click ->
    basicEditorActions.changeTab()