$(document).on 'page:change', ->
  $('#campaigns table').dataTable();
  $('#campaigns_wrapper .table-caption').text('Some header text');
  $('#campaigns_wrapper .dataTables_filter input').attr('placeholder', 'Search...');

  $(".switcher").switcher()
