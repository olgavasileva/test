$(document).on 'page:change', ->
  $('#campaigns table').dataTable();
  $('#campaigns_wrapper .table-caption').text('Some header text');
  $('#campaigns_wrapper .dataTables_filter input').attr('placeholder', 'Search...');

  $(".switcher").switcher()
  $(document).on "change", "[data-active-switcher=true]", (e)->
    url = $(this).data().url
    params = {}
    params[$(this).attr("name")] = this.checked
    $.post url, params

  $dialog = $('#dialog')
  $('.edit-question').click (e)->
    e.preventDefault()
    e.stopPropagation()
    $el = $(@)
    $.ajax
      method: 'GET'
      url: $el.data('url')
      success: (html)->
        $dialog.find('.modal-body').html(html)
        $dialog.modal()

        $dialog.find('input[type="submit"]').click ->
          $dialog.find('form').on 'ajax:success', (e, data) ->
            $el.parent().parent().find('td:first-child a').text(data.title)
          $dialog.modal('hide')

  $('.unit-code').click (e)->
    e.preventDefault()
    e.stopPropagation()

    $el = $(this)
    href = $el.attr('href')
    width = $el.data().width
    height = $el.data().height

    $dialog = $('#dialog')
    $dialog.find('.modal-body').html('<pre>' +
        $('<div></div>').text("<iframe width=\"#{width}\" height=\"#{height}\" src=\"#{href}\" frameborder=\"0\"></iframe>").html() + '</pre>')

    $dialog.modal()
