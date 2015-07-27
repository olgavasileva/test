itemIdx = 0
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

editorConfig =
  theme: 'modern'
  toolbar: 'bold,italic,underline,|,bullist,numlist,outdent,indent,|,undo,redo,|,pastetext,pasteword,selectall,|,uploadimage'
  pagebreak_separator: '<p class=\'page-separator\'>&nbsp;</p>'
  plugins: ['uploadimage']
  relative_urls: false
  remove_script_host: false
  mode: 'exact'
  document_base_url: (if !window.location.origin then window.location.protocol + '//' + window.location.host else window.location.origin) + '/'

window.showEditor = (element) ->
  label = $(element).next('label')
  label.removeClass 'hidden'
  $(element).hide()

window.addItem = ->
  $items = $('.items')
  $items.append('<div class="item">' + itemTemplate() + '</div>')
  $items.find('.item:last-child [rel=tinymce]').tinymce editorConfig

window.removeItem = (el)->
  $el = $(el)
  isItemNew = $el.parents('.item').find('.item-id-field').length == 0
  if isItemNew
    $el.parents('.item').remove()
  else
    $el.parents('.item').addClass('hidden')
    $el.find('[type="checkbox"]').val(1)

$ 'document:ready', ->
  itemIdx = $('.item').length
  $("[rel=tinymce]").tinymce(editorConfig);