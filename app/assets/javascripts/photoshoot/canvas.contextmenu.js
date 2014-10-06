"use strict";
$(function(){

    var canvas;
	var contextMenuDelegateSelector = ".upper-canvas";
	var contextMenuWidth = '120px';
	var uiTemplatesSelector = '#ps-ui-templates';
	var elMenuItemPopup = "#ps-sticker-details";

	/**
	 * Bind
	 */
	$(document).bind("ps.canvas.init.after", function(){				
		canvas = psCanvas();
		init();
		canvas.getContext().on({
			'after:render': function(){
				hideDetails();
			}
		});
	});    			

    /**
     * init
     */ 
    function init(){
		$(".ps-popup-close", elMenuItemPopup).click(function(){
			hideDetails();
			return false;
		});    	
		$(document).contextmenu({
		    delegate: contextMenuDelegateSelector,
		    show: false,
		    hide: false,
		    taphold: true,
		    menu: [{
		    	title: "Move Forward", 
		    	cmd: 'forward',
		    	action: canvas.moveForward
		    },{
		    	title: "Move Backward", 
		    	cmd: 'backward',
		    	action: canvas.moveBackward
		    },{
		    	title: "Flip", 
		    	cmd: 'flip',
		    	action: canvas.flip
		    },{
		    	cmd: "group",
		    	title: "Group", 		    	
		    	action: canvas.group    			    			    	
		    },{
		    	cmd: "ungroup",
		    	title: "Ungroup", 		    	
		    	action: canvas.ungroup    			    			    			    	
		    },{
		    	title: "Delete", 
		    	cmd: 'delete',
		    	action: canvas.remove    			    	
		    },{
		    	title: "Details", 
		    	cmd: 'details',
		    	action: showDetails
		    },{
		    	title: "Show JSON", 
		    	cmd: 'json',
		    	action: canvas.toJSON    			    			    	
		    },{
		    	title: "Set as Avatar", 
		    	cmd: 'avatar',
		    	action: setAsAvatar
		    }],
		    createMenu: function(e, ui){
				$(e.target).width( contextMenuWidth ).appendTo( uiTemplatesSelector );
		    },
		    beforeOpen: function(e, ui){
		    	$(document).trigger("ps.canvas.contextmenu.beforeOpen");
		    	hideDetails();
			    var target = canvas.getContext().findTarget(e.originalEvent, false);

			    if( target != null ){
					$(document).contextmenu("enableEntry", "forward", true);			    	
					$(document).contextmenu("enableEntry", "backward", true);			    						
					$(document).contextmenu("enableEntry", "delete", true);			    	

			    	var activeGroup = canvas.getContext().getActiveGroup();
			    	var activeObject = canvas.getContext().getActiveObject();

					if( activeGroup != null && activeGroup === target ){
						$(document).contextmenu("showEntry", "group", true);
						$(document).contextmenu("showEntry", "ungroup", false);
						$(document).contextmenu("enableEntry", "group", true);
					} else {						
						canvas.getContext().setActiveObject(target);					
						if( target._objects != null ){
							$(document).contextmenu("showEntry", "group", false);
							$(document).contextmenu("showEntry", "ungroup", true);							
						} else {
							$(document).contextmenu("showEntry", "group", true);
							$(document).contextmenu("showEntry", "ungroup", false);
							$(document).contextmenu("enableEntry", "group", false);
						}
					}

			    	if( hasDetails( target.get('psItemId'))) {
			    		$(document).contextmenu("enableEntry", "details", true);
			    	} else {
			    		$(document).contextmenu("enableEntry", "details", false);		
			    	}

			    	if( canvas.hasMirrorableStickers()){
			    		$(document).contextmenu("enableEntry", "flip", true);			    	
			    	} else {
			    		$(document).contextmenu("enableEntry", "flip", false);			    	
			    	}			    	
				} else {
					$(document).contextmenu("enableEntry", "forward", false);			    	
					$(document).contextmenu("enableEntry", "backward", false);			    	
					$(document).contextmenu("enableEntry", "flip", false);			    	
					$(document).contextmenu("enableEntry", "delete", false);			    						
					$(document).contextmenu("showEntry", "group", true);	    	
					$(document).contextmenu("showEntry", "ungroup", false);
					$(document).contextmenu("enableEntry", "group", false);		
					$(document).contextmenu("enableEntry", "details", false);		
				}		

				$(document).contextmenu("showEntry", "json", PS_DEBUG_MODE_ON);
		    }
		});	    
	}	

	function hasDetails( stickerId )
	{
		if( stickerId != null ){
			var sticker = (new psUtils()).getStickerById( stickerId );
	    	if( sticker.product && !_.every( sticker.product, function(v){ return v == '' } )){
	    		return true;
	    	}    				
		}
		return false;
	}

    /**
     *
     */
    function showDetails(event, action)
    {    	
		event.preventDefault();

    	var obj = canvas.getContext().getActiveObject();
    	if( obj == null || obj.get('psItemId') == null ){
    		return;
    	}

    	var sticker = (new psUtils()).getStickerById( obj.get('psItemId') );
    	if( sticker == null || sticker.product == null ){
    		return;
    	}

    	var $menu = action.item.parents('.ui-menu');    			
		var y = $menu.offset().top;
		var x = $menu.offset().left;

		$(document).trigger("ps.stickerDetails.showPopup", [ sticker.id, x, y ]);
    }

    /**
     *
     */
    function hideDetails(){
		$(document).trigger("ps.stickerDetails.hidePopup");
    }    	

    /**
     *
     */
    function setAsAvatar(){
	    var preloader = psUI().showPreloader("Saving to<br/>your gallery");

	    var ret = new $.Deferred();
	    ret.done(function(scene){
	        psNetwork().saveCurrentScene( scene ).complete(function(){
	            preloader.remove();
	            psUI().setAsAvatar();
	        });
	    });
	    $(document).trigger("ps.canvas.serializer.serialize", [ret]);		
    }      
});