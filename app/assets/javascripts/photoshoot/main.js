//=require_self
//=require ./globals.js
//=require ./libs/fabric.js
// require ./libs/jquery-ui-1.10.3.custom.js
// DO WE NEED THIS? =require plugins/jquery-ui.min.js
//=require ./libs/jquery.ui-contextmenu
//=require ./libs/jquery.ba-hashchange.min
// DO WE NEED THIS? =require plugins/jquery.ui.touch-punch.min.js
//=require ./libs/jquery.cookie
//=require ./libs/doubleTap
//=require ./libs/idangerous.swiper-2.0
//=require ./libs/idangerous.swiper.scrollbar-2.0
//=require ./libs/jquery.rcrumbs
//=require handlebars
//=require ./ui
//=require ./utils
//=require ./canvas
// require ./canvas.contextmenu
//=require ./canvas.trashcan
//=require ./canvas.serializer.common
//=require ./canvas.serializer
//=require ./canvas.stickermenu
//=require ./canvas.undoredo
//=require ./sticker-details
//=require ./network
//=require ./bootstrap
// DO WE NEED THIS? =require plugins/modernizr.custom.js
//=require ./libs/underscore

$(function() {
    $(document).bind("ps.bootstrap.initialized", function() {
        if ($("#sceneinfo").length > 0) {
            var sceneData = $("#sceneinfo").data();

            setTimeout(function() {
                psUtils().setStickers(sceneData.stickers);
                psNetwork().getScaledScene(sceneData.sceneId, function(data) {
                    if (sceneData.sceneUserId != undefined) {
                        psCanvas().loadScene(data);
                    } else {
                        psCanvas().loadScene(data, psUI().saveSceneAfterLogin);
                    }
                });
            }, 300);
        }
    });
});