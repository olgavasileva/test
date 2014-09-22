$('#recent_comments').html("<%= j render 'users/dashboard/recent_comments' %>")
$('#recent_comments').trigger 'html:loaded'