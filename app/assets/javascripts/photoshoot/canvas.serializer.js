"use strict";
$(function(){

    var canvas;

	/**
	 * Bind
	 */
	$(document).bind("ps.canvas.serializer.serialize", serialize);
	$(document).bind("ps.canvas.serializer.deserialize", deserialize);
	$(document).bind("ps.canvas.init.after", init);    				

	/**
	 * 
	 */
	function init()
	{
		canvas = psCanvas().getInstanceOfFabricJS();		
	}	

	/**
	 * 
	 */
    function serialize(event, dfd, onlySelectedObjects)
    {
		var obj = canvas.getActiveObject();
		var grp = canvas.getActiveGroup();
		var propertiesToInclude = ['psOrigWidth', 'psOrigHeight', 'psType', 'psItemId'];
		var json;
		var data = {
			objects: []			
		};

		if( onlySelectedObjects && obj != null ){
			json = obj.toJSON(propertiesToInclude);
			data.objects = parseObjectToAPIFormat(json, 0);
		}
		else if( onlySelectedObjects && grp != null ){
			json = grp.toJSON(propertiesToInclude);
			data.objects = parseObjectToAPIFormat(json, 0);
		}
		else {
			json = canvas.toJSON(propertiesToInclude);
			data.objects = filterInvisibleObjects( json.objects );
			data.objects = _.map( data.objects, parseObjectToAPIFormat );			
			data.backgrounds = [];
			if( json.backgroundImage != null ){
				data.backgrounds = [{
					id: psUtils().getStickerByImageURL( json.backgroundImage ).id
					,transparency: 100
					,z_index: 0
				}];
			}
		}

		var s = JSON.stringify( data , null, 4 );

    	dfd.resolve(s);    	
    }

	/**
	 * 
	 */
    function deserialize(event, data, dfd)
    {
        var json = (typeof data == 'string') ? $.parseJSON(data) : data;
    	dfd.resolve( parseSceneFromAPIFormat(json) );
    }    	

	/**
	 * Remove objects that are not visible or have been placed out of border.
	 */
    function filterInvisibleObjects( objects )
    {
    	var cw = canvas.getWidth();
    	var ch = canvas.getHeight();
    	
    	return _.filter( objects, function(obj){
    		if( obj.visible == false ){
    			return false;
    		}
    		if( obj.originX == "center" ){
    			if( obj.left - obj.width / 2 > cw || obj.left + obj.width / 2 < 0 ){
    				return false;
    			}
    		}
    		if( obj.originY == "center" ){
    			if( obj.top - obj.height / 2 > ch || obj.top + obj.height / 2 < 0 ){
    				return false;
    			}
    		}    		    	
    		return true;
    	});
    }

    /**
     *
     */
    function parseObjectToAPIFormat( obj, zIndex )
    {    	
    	var newObj = {    		
			originY: obj.originY
			,originX: obj.originX
			,x: Math.ceil( obj.left )
			,y: Math.ceil( obj.top )
			,width: Math.ceil( obj.width )
			,height: Math.ceil( obj.height )
			,rotation: obj.angle
			,scale: obj.scaleX
			,flipped: obj.flipX
			,z_index: zIndex
    	};      	
    	if( obj.type == "group" && _.isArray( obj.objects )){
    		newObj.is_group = true;
    		newObj.objects = _.map( obj.objects, parseObjectToAPIFormat );
    	} else {
    		newObj.is_group = false;
    		newObj.id = obj.psItemId;
    		newObj.type = obj.psType;
    	}

    	return newObj;
    }  
});