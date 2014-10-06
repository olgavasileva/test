"use strict";
$(function(){

    var canvas;
    var menu;
	var contextMenuDelegateSelector = ".upper-canvas";	

	/**
	 * Bind
	 */
    $(document).on('click', function(event, target){

        var onCanvas = $(event.target).parents().hasClass('canvas-container');
        if (!onCanvas ){
            $(document).trigger('ps.canvas.stickermenu.hideContextMenu');
        }
    });
	$(document).bind("ps.canvas.stickermenu.hideContextMenu", hideContextMenu);
	$(document).bind("ps.canvas.stickermenu.showContextMenu", function(event, target){
		showContextMenu(target);
	});
	$(document).bind("ps.canvas.init.after", function(){				

		$("#ps-sticker-details").find(".ps-popup-close").click(function(){
			hideDetails();
			return false;
		});

		canvas = psCanvas();
        var objUI;

	    canvas.getContext().on({
	    	'object:selected': function(options){		    		    
	    		if( options.e != null ){ // protection from recursion
                    showObjUI(options.target);
	    		}
	    	},
	    	// will display menu after moving/editing
	    	'object:modified': function(options){
	    		//showContextMenu( options.target );
                deselectObject();
	    	},
	    	'selection:created': function(options){	    		
				//showControls( options.target );
                //showContextMenu( options.target );
	    	},
	    	'selection:cleared': hideContextMenu,
	    	'object:moving': function(options){
                hideObjUI(options.target);
            },
			'after:render': hideDetails
	    });

        function deselectObject(){
            //canvas.getContext().deactivateAll();
            canvas.getContext().discardActiveObject();
        }
        function showObjUI(obj){
            objUI = setTimeout(function(){
                showControls( obj );
                showContextMenu( obj );
            }, 250);
        }
        function hideObjUI(obj){
            clearTimeout(objUI);
            hideControls(obj);
            hideContextMenu();
        }
        function hideControls(obj){
            obj.set({
                hasBorders: false,
                hasControls: false
            });
        }
        function showControls(obj){
            obj.set({
                hasBorders: true,
                hasControls: true
            });
        }
	});

	$(document).bind('ui.clearAll.after', function(){
		hideContextMenu();
	});		

	$(document).bind("ps.canvas.contextmenu.beforeOpen", function(){
		hideContextMenu();
	});

	function showContextMenu(target){				
		hideContextMenu();
		hideDetails();
		menu = createMenu( target );
		menu.show();

    var desktop =  $("#ps-desktop");
    var x;
		var y = target.top - target.getHeight() / 2;

    //Make sure the menu stays inside the canvas
    if(y < 0){
      y = 0;
    } else if(y >= (desktop.height() - menu.find(".ps-ctx-background").height())) {
      y = desktop.height() - menu.find(".ps-ctx-background").height() - 1;
    }

    if(target.left <= desktop.width() / 2){
      //If the image is on the left side of the canvas, put the menu on the right.
      x = target.left + 10 + target.getWidth() / 2;
    } else {
      //If the image is on the right side of the canvas, put the menu on the left.
      x = target.left - 10 - (target.getWidth() / 2) - menu.find(".ps-ctx-background").width();
    }

		menu.position({
			'of': desktop,
			'my': "left center",
			'at': "left+" + x + " top+" + y
		});
	}

	function hideContextMenu(){
		if( menu ){
			menu.remove();
			menu = null;
		}
	}    

	function customizeMenu( items, target )
	{
	    if( target != null ){
	    	var activeGroup = canvas.getContext().getActiveGroup();
	    	var activeObject = canvas.getContext().getActiveObject();

			if( activeGroup != null && activeGroup === target ){
				items.ungroup = null;
			} else {						
				canvas.getContext().setActiveObject(target);					
				if( target._objects != null ){
					items.group = null;
				} else {
					items.group = null;
					items.ungroup = null;
				}
			}

	    	if( ! hasDetails( target.get('psItemId'))) {	    		
	    		items.details = null;
	    	}

	    	if( ! canvas.hasMirrorableStickers()){
	    		items.flip = null;
	    	}			    	
		}		

		if( PS_DEBUG_MODE_ON !== true ){
			items.json = null;
            items.avatar = null; //Hide the Set as Avatar option for now.
		}

		return items;	
	}

	function createMenu( target )
	{
		var items = {
			forward: {
				title: "Forward",
				style: "ps-ctx-forward"
			},
			backward: {
				title: "Backward",
				style: "ps-ctx-backward"
			},
			flip: {
				title: "Flip",
				style: "ps-ctx-flip"
			},
			group: {
				title: "Group",
				style: "ps-ctx-group"
			},
			ungroup: {
				title: "Ungroup",
				style: "ps-ctx-ungroup"
			},
			remove: {
				title: "Remove",
				style: "ps-ctx-remove"
			},
//			details: {
//				title: "Details",
//				style: "ps-ctx-details"
//			},
			json: {
				title: "Show JSON",
				style: ""
			},
			avatar: {
				title: "Set as Avatar",
				style: "ps-ctx-avatar"
			}
		};

		items = customizeMenu( items, target );

		var itemsLength = 0;
		var list = $("<ul>");
		$.each( items, function(k, v){			
			if( v != null ){
				itemsLength++;
				list.append(
					$("<li>").addClass( v.style ).attr('data-action', k).append( 
						$('<i>'), v.title					
					)
				);
			}
		});

    var arrow = 'ps-ctx-arrow-right';
    if(target.left <= $("#ps-canvas").width() / 2)
     arrow = 'ps-ctx-arrow-left';

		var menu = $("<div>").addClass('ps-ctx').append(
			$("<div>").addClass('ps-ctx-background').append(
				$("<div>").addClass(arrow)
			),
			$("<div>").addClass('ps-ctx-inner').append( list )
		);
		
		menu.find('.ps-ctx-background').css({ height: itemsLength * 36 });
		menu.find('.ps-ctx-inner').css({ height: itemsLength * 36 });				
		menu.find('li').click(function( event ){		
			event.preventDefault();			
			switch( $(this).data('action') )
			{
				case "forward":
					canvas.moveForward();
					break;

				case "backward":
					canvas.moveBackward();
					break;

				case "flip":
					canvas.flip();
					break;

				case "group":
					canvas.group();
					hideContextMenu();
					break;

				case "ungroup":
					canvas.ungroup();
					hideContextMenu();
					break;										

				case "remove":
					canvas.remove();
					hideContextMenu();
					break;

				case "json":
					canvas.toJSON();
					hideContextMenu();
					break;

				/*
				case "details":
					showDetails( event );
					hideContextMenu();
					break;	
                */
				case "avatar":
					setAsAvatar();
					hideContextMenu();
					break;														
			}				
			return false;
		});				

		menu.appendTo('body');
		return menu;
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
    function showDetails(event)
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

		var y = menu.offset().top;
		var x = menu.offset().left;
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
    	canvas.getContext().deactivateAll();
    	canvas.getContext().renderAll();
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
