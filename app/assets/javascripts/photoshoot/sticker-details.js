"use strict";
$(function(){

	var menuItemPopupTimer = null;

	/**
	 * Bindings
	 */
	$(document).click( function(event) {			
		var popup = $(event.target).closest('.psPopupForMenu')[0];		
		if( popup != null ){
			return false;
		} else {
			$('.psPopupForMenu').remove();
		}
	});	

	// Enable tap & dbltap events

   /* $(document).dblclick( showPopup );

    var myElem = document.getElementById('pack-wrapper');
	if( 'ontouchend' in myElem ){
		myElem.addEventListener('touchend', doubleTap(), false);
		myElem.addEventListener('dbltap', showPopup, false);
	}

	$(document).bind("ui.createStickerItems.after", function( event, menuContainer ){
		bindHoverForStickerItems( menuContainer );
	});

	$(document).bind("ps.stickerDetails.showPopup", function(event, stickerId, left, top ){
		showPopupForCanvas( stickerId, left, top );
	});
	$(document).bind("ps.stickerDetails.hidePopup", function(){
		$('.psPopupForCanvas').remove();
	});

	*/
    /**
	 *
	 *//*
	function showPopup(event) {
		var item = $(event.target).closest('.stickable').find('img')[0];
		if( item != null ){
			var data = $(item).data();
			if( _.isObject( data ) && data.id != null ){
				showPopupForMenu( item, data.id );
			}
			return false;
		}
	}
*/
	/**
	 *
	 */
    /*
	function bindHoverForStickerItems( container ){
		$(container).find('.stickable').hover(
			function () {
				var item = this;
				var data = $(this).find('img').data();
				if( _.isObject( data ) && data.id != null ){
					clearTimeout(menuItemPopupTimer);
					menuItemPopupTimer = setTimeout(function(){
						showPopupForMenu( item, data.id )						
					}, 1500);
					
				}
			},
		  	function () {
		  		clearTimeout(menuItemPopupTimer);
		  		var is_touch_device = 'ontouchstart' in document.documentElement;
		  		if( is_touch_device == false ){
			  		menuItemPopupTimer = setTimeout(function(){
			  			$('.psPopupForMenu').remove();
			  		}, 500 );
		  			$('.psPopupForMenu').one('mouseover', function(){
		  				clearTimeout(menuItemPopupTimer);
		  			});
		  		}
		  	}
		);		
	}*/

	/**
	 *
	 */
	/*function showPopupForMenu( menuItem, stickerId ){
		$('.psPopupForMenu').remove();
		var psItemHalfWidth = Math.round((PS_ITEMS_MENU_CELL_WIDTH + PS_ITEMS_MENU_CELL_MARGIN * 2) / 2);
		psItemHalfWidth -= 11; // width of the arrow		

		var tpl = getTemplate( stickerId, false, 'psPopupForMenu');
		if( tpl != null ){
			tpl.appendTo("#ps-ui-templates");
			tpl.position({
		    	my: "left+"+psItemHalfWidth+" center-6",
		    	of: menuItem,
		    	collision: "fit"
			});		
		}
	}*/

    /**
     *
     */
    function showPopupForCanvas( stickerId, left, top )
    {    	
    	$('.psPopupForCanvas').remove();
		var tpl = getTemplate( stickerId, true, 'psPopupForCanvas');
		if( tpl != null ){
			tpl.appendTo("#ps-ui-templates");
			tpl.position({
				my: "left center",
		    	at: "left+"+left+" top+"+top,
		    	of: $('body'),
		    	collision: "fit"
			});				
		}
    }	

	/**
	 *
	 */
  function getTemplate( stickerId, withIcon, addClass )
  {
    var sticker = (new psUtils()).getStickerById( stickerId );
    if( sticker == null || sticker.product == null || sticker.product.length == 0 ){
      return;
    }

    if( sticker.type == "Background" ){
      return;
    }

    if( _.every( sticker.product, function(v){ return v == '' } )){
      return;
    }

    var price = sticker.product.price;
    var name = sticker.display_name;
    var info = sticker.product.info;
    var cart = sticker.product.add_to_cart;
    var url = sticker.product.url;

    var tpl = $('<div>').addClass('ps-sticker-details ps-menu-popup ps-menu' + ( addClass == null ? '' : ' ' + addClass )).append(
      $('<div>').append(
        $('<div>').addClass('ps-popup-content').append(
          $('<div>').addClass('ps-popup-name').html( name ),
          $('<div>').addClass('ps-popup-info').html( info ),
          (!url) ? null : $('<div>').addClass('ps-popup-details').append(
            $('<a>').attr('href', url).attr('target', '_blank').text('View details')
          ),
          price == '' ? null : $('<div>').addClass('ps-popup-price').append(
            $('<span>').html( price )
          ),
          cart == '' ? null : $('<a>').addClass('ps-popup-cart').attr('href', cart).attr('target', '_blank'),
          $('<a>').addClass('ps-popup-close').attr('href', '#').click(function(){
            $(this).closest('.ps-sticker-details').remove();
            return false;
          })
        )
      )
    );

    if( withIcon ){
      var $img = $("<div>").addClass('ps-popup-image');
      var size = psUI().resizeImageForMenu( sticker.type, sticker.image_width, sticker.image_height, PS_ITEMS_MENU_CELL_WIDTH, PS_ITEMS_MENU_CELL_HEIGHT );

      $img.css('background-size', size.width + "px " + size.height + "px" );
      $img.css('background-position', size.posX + "px " + size.posY + "px" );
      $img.css('background-image', "url(" + sticker.image_url + ")" );
      $img.css('background-repeat', "no-repeat" );

      $img.prependTo( tpl.children() );
      $("<div>").css('clear', 'both').appendTo( tpl.children() );
      $('.ps-popup-content', tpl).css('margin-left', '118px');
    }

    return tpl;
  }
});
