Gaffe.configure do |config|
  config.errors_controller = {
      %r[/users/] => 'DashboardErrorsController',
      %r[/\.*] => 'ErrorsController'
  }
end
Gaffe.enable!