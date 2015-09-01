itemIdx = 0
editorConfig = null
itemTemplate = ->
  itemIdx += 1

  "<fieldset id=\"#{itemIdx - 1}_fieldset\"><div class=\"title\">Item ##{itemIdx}</div><br>" +
    '<button class="delete-item" onclick=\"removeItem(this)\" type="button"><i class="fa fa-times"></i></button>' +
    "<input name=\"listical[questions_attributes][#{itemIdx}][_destroy]\" type=\"hidden\" value=\"0\">" +
    "<input class=\"hidden\" id=\"listical_questions_attributes_#{itemIdx}__destroy\" " +
    " name=\"listical[questions_attributes][#{itemIdx}][_destroy]\" type=\"checkbox\" value=\"1\">" +
    "<label for=\"listical_questions_attributes_#{itemIdx}_title\">Title</label>" +
    "<input id=\"listical_questions_attributes_#{itemIdx}_title\" name=\"listical[questions_attributes][#{itemIdx}][title]\" type=\"text\">" +
    "<br><label for=\"listical_questions_attributes_#{itemIdx}_question\"><textarea id=\"listical_questions_attributes_#{itemIdx}_body\" " +
    "name=\"listical[questions_attributes][#{itemIdx}][body]\" rel=\"tinymce\"></textarea></label></fieldset>"

window.showEditor = (element) ->
  label = $(element).next('label')
  label.removeClass 'hidden'
  $(element).hide()

refreshIndexes = ->
  $('.item').each (i, e)->
    $(e).find('.title').text "Item ##{i + 1}"


window.addItem = ->
  $items = $('.items')
  $items.append('<div class="item">' + itemTemplate() + '</div>')
  $items.find('.item:last-child [rel=tinymce]').tinymce editorConfig
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
  itemIdx = $('.item').length
  editorConfig =
    toolbar: 'fontselect,|,bold,italic,underline,|,formatselect,|,forecolor,backcolor,|,bullist,numlist,outdent,indent,|,undo,redo,|,pastetext,pasteword,selectall,|,uploadimage,media'
    pagebreak_separator: '<p class=\'page-separator\'>&nbsp;</p>'
    extended_valid_elements: "iframe[src|frameborder|style|scrolling|class|width|height|name|align]"
    plugins: ['uploadimage', 'textcolor', 'media']
    relative_urls: false
    remove_script_host: false
    mode: 'exact'
    statusbar: false
    uploadimage_form_url: window.tinymceImageUploadPath
    document_base_url: (if !window.location.origin then window.location.protocol + '//' + window.location.host else window.location.origin) + '/'

  $('[rel="tinymce"]').tinymce(editorConfig)

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

$(document).on 'page:receive', ->
  tinymce.remove()
