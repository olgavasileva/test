// This file holds functions needed by both the web and node.js to de-serialize scenes

/**
 *
 */
function parseObjectFromAPIFormat( obj )
{
    var base = {
        angle: obj.rotation
        ,clipTo: null
        ,fill: "rgb(0,0,0)"
        ,filters: Array[0]
        ,flipX: obj.flipped
        ,flipY: false
        ,hasBorders: true
        ,hasControls: true
        ,hasRotatingPoint: true
        ,height: obj.height
        ,left: obj.x
        ,opacity: 1
        ,originX: obj.originX
        ,originY: obj.originY
        ,overlayFill: null
        ,perPixelTargetFind: false
        ,scaleX: obj.scale
        ,scaleY: obj.scale
        ,selectable: true
        ,shadow: null
        ,stroke: null
        ,strokeDashArray: null
        ,strokeLineCap: "butt"
        ,strokeLineJoin: "miter"
        ,strokeMiterLimit: 10
        ,strokeWidth: 1
        ,top: obj.y
        ,transparentCorners: true
        ,visible: true
        ,width: obj.width
    }



    if( obj.is_group ){
        base.type = "group";
        var objectsSorted = sortObjectsByZIndex( obj.objects );
        base.objects = _.map( objectsSorted, parseObjectFromAPIFormat );
        base.psOrigWidth = obj.width * obj.scale;
        base.psOrigHeight = obj.height * obj.scale;
    } else {
        var item = new psUtils().getStickerById( obj.id );
        if( item == null ){
            return null;
        }
        base.type = "image";
        base.src = item.image_url;
        base.psItemId = item.id;
        base.psType = item.type;
        base.psOrigWidth = item.image_width;
        base.psOrigHeight = item.image_height;
    }
    return base;
}

/**
 *
 */
function sortObjectsByZIndex( objects ){
    return _.sortBy( objects, function(obj, index, ctx){
        return obj.z_index;
    });
}

function parseSceneFromAPIFormat( json ){
    var result = {};
    
    if( json.objects ){
        var objectsSorted = sortObjectsByZIndex( json.objects );
        result.objects = _.map( objectsSorted, parseObjectFromAPIFormat );
    }
    if (json.backgrounds && json.backgrounds[0]) {
        var background = new psUtils().getStickerById( json.backgrounds[0].id );
        if( background != null ) {
            result.backgroundImage = background.image_url;
            result.backgroundImageOpacity = 1;
            result.backgroundImageStretch = true;
        }
    }

    return result;
}

if (typeof exports != 'undefined') {
    exports.parseSceneFromAPIFormat = parseSceneFromAPIFormat;
}