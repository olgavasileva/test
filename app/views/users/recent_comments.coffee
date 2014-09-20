$('#recent_comments').html("<%= j render 'users/pro/recent_comments' %>")
$('#recent_comments').trigger 'html:loaded'