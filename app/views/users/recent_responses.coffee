$('#recent_responses').html("<%= j render 'users/pro/recent_responses' %>")
$('#recent_responses').trigger 'html:loaded'