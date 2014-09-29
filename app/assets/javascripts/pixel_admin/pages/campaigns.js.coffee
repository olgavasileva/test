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
