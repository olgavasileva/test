var iframe = document.createElement('iframe');
iframe.width = statisfy_unit_width;
iframe.height = statisfy_unit_height;
iframe.scrolling = 'no';
iframe.src = "http://a.statisfy.co/unit/" + statisfy_unit;
iframe.frameBorder = 0;
document.body.appendChild(iframe);