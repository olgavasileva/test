"use strict";
$(function(){

    var canvas;
    var overlay;
    var trashCan;
    var intersects = false;
    var studio = $("#studio-wrapper");

	/**
	 * Bind
	 */
	$(document).bind("ps.canvas.init.after", function(){				
		canvas = psCanvas().getContext();
		init();
	});    			

	function showTrashZone()
	{
		if( overlay ){
			return;
		}

		function calcSize(){
//      var menu = $('#asset-wrapper');
//      var titleHeight = $("#title-bar").height();
      var psCanvas = $("#ps-canvas");
      var breadcrumbHeight = PS_HEADER_HEIGHT;

			return {
				w: psCanvas.offset().left,//menu.width(),
				h: psCanvas.height(),// - breadcrumbHeight - 4,
				top: 0 + breadcrumbHeight + 2,//studio.offset().top + breadcrumbHeight + 2,//0 + titleHeight,
				left: 0,
        right: 0
			}
		}

		var size = calcSize();
		overlay = $('<div>').css({
	    	'background': 'rgba(0, 0, 0, .8)',
	    	'width': size.w,
	    	'height': size.h,
	    	'position': 'absolute',
	    	'top': size.top,
	    	'right': size.right,
//	    	'left': size.left,
	    	'z-index': 100,
	    	'cursor': 'pointer'
	    });

		trashCan = $('<div>').css({
	    	'width': size.w,
	    	'height': size.h,
	    	'position': 'absolute',
	    	'top': size.top,
	    	'right': size.right,
//	    	'left': size.left,
	    	'z-index': 101,
	    	'cursor': 'pointer'
		}).append(
			$('<div>').addClass('ps-trashcan')
		);

		trashCan.hover(
			function(){
				$(this).find('.ps-trashcan').fadeTo("fast", 0.33);
				intersects = true;
			},
			function(){
				$(this).find('.ps-trashcan').fadeTo("fast", 1);
				intersects = false;
			}
		);

		$(window).on('resize.canvasTrashCan', function(){			
			var size = calcSize();
			overlay.css({
		    	'width': size.w,
		    	'height': size.h,
		    	'top': size.top,
		    	'right': size.right
//		    	'left': size.left
		    });
			trashCan.css({
		    	'width': size.w,
		    	'height': size.h,
		    	'top': size.top,
		    	'right': size.right
//		    	'left': size.left
		    });
		});
    studio.append( overlay );
    studio.append( trashCan );
	}

	function hideTrashZone()
	{
		$(window).off('resize.canvasTrashCan');
		intersects = false;
		if( overlay ){			
			overlay.remove();
			overlay = null;
			trashCan.off('mouseenter mouseleave');
			trashCan.remove();
			trashCan = null;
		}
	}

    /**
     * init
     */ 
    function init(){    	
	    canvas.on({
	    	'object:moving': function(options){	    	
				showTrashZone();
				if( intersects ){
					options.target.setOpacity(0.5);
				} else {
					options.target.setOpacity(1);
				}								
	    	}
	    	,
	    	'mouse:up': function(options){
	    		if( intersects )
	    		{
	    			var target = canvas.getActiveObject() || canvas.getActiveGroup();
	    			canvas.deactivateAll();		    		
	    			
	    			if( target != null  && target.get('opacity') == 0.5 ){
	    				if( target._objects != null ){
	    					var objects = target.getObjects();
		    				_.each( objects, function(obj){		    					
								canvas.remove( obj );
		    				});
	    				}
	    				canvas.remove( target );
	    			}
					$(document).trigger("ps.canvas.stickermenu.hideContextMenu");
		    		canvas.deactivateAll();		    		
		    		canvas.renderAll();
	    		}
				hideTrashZone();
	    	}
	    });    	
    }
});    