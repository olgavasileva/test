$('#recent_responses').html("<%= j render 'users/dashboard/recent_responses' %>")
$('#recent_responses').trigger 'html:loaded'