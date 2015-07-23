var iframe = document.createElement('iframe');
iframe.width = statisfy_unit_width;
iframe.height = statisfy_unit_height;
iframe.scrolling = 'no';
iframe.src = "http://labs.statisfy.co/qp/" + statisfy_unit + '/' + (statisfy_unit_type || 'medium_rectangle');
iframe.frameBorder = 0;
document.body.appendChild(iframe);
