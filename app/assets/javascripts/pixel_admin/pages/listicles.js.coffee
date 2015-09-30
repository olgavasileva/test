itemIdx = 0
editorConfig = null
itemTemplate = ->
  itemIdx += 1

  "<fieldset id=\"#{itemIdx - 1}_fieldset\"><div class='left-side'><div class=\"title\">Item ##{itemIdx}</div><br>" +
    '<button class="delete-item" onclick=\"removeItem(this)\" type="button">[X] Remove Item</button></div>' +
    "<input name=\"listicle[questions_attributes][#{itemIdx}][_destroy]\" type=\"hidden\" value=\"0\">" +
    "<input class=\"hidden\" id=\"listicle_questions_attributes_#{itemIdx}__destroy\" " +
    " name=\"listicle[questions_attributes][#{itemIdx}][_destroy]\" type=\"checkbox\" value=\"1\">" +
    "<label for=\"listicle_questions_attributes_#{itemIdx}_question\"><textarea id=\"listicle_questions_attributes_#{itemIdx}_body\" " +
    "name=\"listicle[questions_attributes][#{itemIdx}][body]\" rel=\"redactor\"></textarea></label></fieldset>"

window.showEditor = (element) ->
  label = $(element).next('label')
  label.removeClass 'hidden'
  $(element).hide()

refreshIndexes = ->
  $('.item').each (i, e)->
    $(e).find('.title').text "Item ##{i + 1}"


window.addItem = ->
  $el = $('<div class="item">' + itemTemplate() + '</div>')
  $('.items').append($el)
  $el.find('[rel=redactor]').redactor editorConfig
  refreshIndexes()

window.removeItem = (el)->
  $el = $(el)
  isItemNew = $el.parents('.item').find('.item-id-field').length == 0
  if isItemNew
    $el.parents('.item').remove()
  else
    $el.parents('.item').addClass('hidden')
    $el.find('[type="hidden"]').val(1)
  refreshIndexes()

ready = ->
  editorConfig =
    plugins: ['imagemanager', 'video', 'table', 'fontcolor', 'fontfamily', 'fontsize'],
    imageUpload: window.imageUploadPath

  $('[rel=redactor]').redactor editorConfig

  itemIdx = $('.item').length
  getCodeTemplate = (link, width = 600, height = 600)->
    "&lt;div style=\"height: #{height}px; width: #{width}px;\"&gt;&lt;iframe width=\"#{width}\" height=\"#{height}\" src=\"#{link}\" frameborder='0' &gt;&lt;/iframe&gt;&lt;div&gt;"

  $('.embed-code').click (e)->
    e.preventDefault()
    e.stopPropagation()

    $el = $(this)
    href = $el.attr('href')

    $('#dialog').html "<div><label>Height: <input type='number' id='iframe-height' style='font-weight: normal; width: 70px' value='600'></label>" +
        "&nbsp;<a href='" + href + "' id='preview-dialog'><i class='fa fa-eye'></i> Preview</a>" +
        "<br><br><pre id='iframe-code'>#{getCodeTemplate(href)}</pre></div>"

    $('#preview-dialog').click (e)->
      e.preventDefault()
      e.stopPropagation()
      window.open($(this).attr('href'), "_blank", "status=no, width=620, height=" + $('#iframe-height').val() + ", resizable=yes," +
          " toolbar=no, menubar=no, scrollbars=yes, location=no, directories=no")

    $('#dialog').dialog()
    $("#iframe-height").keyup ->
      $('#iframe-code').html getCodeTemplate(href, 600, $(this).val())

  $('.preview-button').click (e)->
    e.preventDefault()
    e.stopPropagation()
    window.open($(this).attr('href'), "_blank", "status=no, width=620, height=480, resizable=yes," +
        " toolbar=no, menubar=no, scrollbars=yes, location=no, directories=no")

$ 'document:ready', ready
$(document).on 'page:load', ready

#$(document).on 'page:receive', ->
#  tinymce.remove()