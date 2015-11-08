currentTab = 'Basic'

getListicleId = -> $('input[name="listicle_id"]').val()
setListicleId = ->
  listicleId = getListicleId()

class EditorActions
  constructor: ->
    @listicleForm = $('#listicle-form')
    @loadingEl = $('#loading-indicator').hide()
  getForm: ->
    @listicleForm.find('form')
  showLoading: ->
    @loadingEl.show()
  hideLoading: ->
    @loadingEl.hide()
  setForm: (form)->
    @listicleForm.html(form)
    @listicleForm.find('[rel=redactor]').redactor window.editorConfig
    window.openThemeEditor()
    setListicleId()
  setCurrentTab: (tabName)->
    currentTab = tabName
    navBarItems = $('ul.nav.nav-tabs li')
    navBarItems.removeClass('active')
    navBarItems.each((i, el)->
      if $(el).text().trim() == tabName
        $(el).addClass('active')
    )
  getUrl: ->
    listicleId = getListicleId()
    editActionRegex = /\/edit$/
    prefix = if window.location.pathname.match(editActionRegex) then '../' else './'

    if listicleId
        prefix + listicleId + '/'
    else
      prefix

class BasicEditorActions extends EditorActions
  save: ->
    listicleId = getListicleId()
    formData = @getForm().serializeArray()
    method = if listicleId then 'PATCH' else 'POST'

    console.log 'saving listicle basic'
    $.ajax
      url: @getUrl()
      data: formData
      method: method
      dataType: 'json'
  changeTab: ->
    return if currentTab == 'Advanced'
    self = @
    @showLoading()
    @save().then((response)->
      self.setForm(response.form)
      self.setCurrentTab('Advanced')
    ).always -> self.hideLoading()

class AdvancedEditorActions extends EditorActions
  save: ->
    listicleId = getListicleId()
    console.log 'saving listicle advanced'
    formData = @getForm().serializeArray()
    $.ajax
      url: "./#{@getUrl()}advanced_form"
      data: formData
      method: 'PATCH'
      dataType: 'json'
  changeTab: ->
    return if currentTab == 'Basic'
    self = @
    @showLoading()
    @save().done((response)->
      self.setForm(response.form)
      self.setCurrentTab('Basic')
    ).always -> self.hideLoading()

$(document).ready ->
  basicEditorActions = new BasicEditorActions()
  advancedEditorActions = new AdvancedEditorActions()
  $('#listicle-form-tab').click ->
    advancedEditorActions.changeTab()
  $('#advanced-listicle-form-tab').click ->
    basicEditorActions.changeTab()
  $('#theme-editor').click ->
    $('#theme-editor-modal').modal 'show'
    $('input.minicolor-input').minicolors
      position: 'bottom right'
      theme: 'default'
      show: null