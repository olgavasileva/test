"use strict";
var psUtils = function() {
    /**
     * Singleton constructor
     */
    if (psUtils.prototype._instance) {
        return psUtils.prototype._instance;
    }
    psUtils.prototype._instance = this;
  //    var menusDB = [];
    var stickersDB = {},
      packsDB = {},
      packOrder = [],
      currentPackId = {},
    stickerPropsList={
      Calories:{node_id:"#calorie-counter"},
      Protein:{node_id:"#protein-counter"},
      Sugar:{node_id:"#sugar-counter"},
      Carbohydrates:{node_id:"#carbohydrates-counter"},
      Fat:{node_id:"#total-fat"},
      Fiber:{node_id:"#fiber-counter"},
      CaloriesFromFat:{node_id:"#calories-from-fat"}
    };
    /**
     * Returns menu item info by hash path
     */
    //	this.findMenuByPath = function( path )
    //	{
    //		var realPath = [];
    //		var wrongUrl = false;
    //
    //		if( path == null || path == '' ){
    //			return menusDB;
    //		}
    //
    //		var result = _.reduce(path, function(menu, param){
    //			var item;
    //			if( wrongUrl !== true ){
    //				item = _.find(menu.sticker_packs, function(item){ return item.id == param });
    //			}
    //			if( item === undefined || item === null ){
    //				wrongUrl = true;
    //				return menu;
    //			} else {
    //				realPath.push(item.id);
    //				return item;
    //			}
    //		}, {
    //			sticker_packs: menusDB
    //		});
    //
    //		if( wrongUrl === true ){
    //			throw realPath;
    //		}
    //
    //		return result;
    //	};

    /**
     *
     */
    this.getDialogConfig = function(config) {
        return _.extend({
            position: "center",
            modal: true,
            autoOpen: false,
            resizable: false,
            create: function(event, ui) {
                $(this).closest(".ui-dialog").appendTo('#ps-ui-templates');
            },
            open: function(event, ui) {
                $('.ui-widget-overlay').prependTo("#ps-ui-templates");
            }
        }, config);
    };

    /**
     *
     */
    this.getStickerById = function(id) {
        return stickersDB[id];
        // return _.find( stickersDB, function( sticker ){
        // 	return sticker.id == id;
        // });
    };

    /**
     *
     */
    this.getStickerByImageURL = function(imgUrl) {
        return _.find(stickersDB, function(sticker) {
            return sticker.image_url == imgUrl || sticker.img_2_url == imgUrl;
        });
    };

    /**sss
     *
     */
    this.setStickers = function(stickers) {
        _.each(stickers, function(sticker) {
            stickersDB[sticker.id] = sticker;
        });
    };

    this.setPacks = function(packs) {
        var currentTime = new Date().getTime();
        _.each(packs, function(p) {
            //Setting up the lock information here to reduce the handlebar ridiculousness that would otherwise ensue
            p.lock_status = 'Free';
            p.is_locked = false;
            if (p.unlocked) {
                p.lock_status = 'Unlocked';
            } else {
                if (typeof p.lock != 'undefined') {
                    var starts = new Date(p.lock.starts_at).getTime();
                    var expires = new Date(p.lock.expires_at).getTime();

                    if (starts > 0) { //If a start date is provided
                        if (starts >= currentTime) {
                            p.lock_status = 'Locked';
                            p.is_locked = true;
                        }
                    } else if (expires > 0) { //If an expires date is provided
                        if (expires <= currentTime) {
                            p.lock_status = 'Locked';
                            p.is_locked = true;
                        }
                    }
                    if ((p.lock.points != null && p.lock.points > 0) || p.lock.challenge_id != null) {
                        p.lock_status = 'Locked';
                        p.is_locked = true;
                    }
                }
            }
            packsDB[p.id] = p;
            packOrder.push(p.id);
        });
    };

    this.getPackByID = function(id) {
        return packsDB[id];
    };

    this.getPacks = function() {
        return _.map(packOrder, function(id) {
            return packsDB[id];
        });
    };

    this.setCurrentPackId = function(id) {
        currentPackId = id;
    };

    this.getCurrentPack = function() {
        return packsDB[currentPackId]
    };

    this.countPacks = function() {
        return packOrder.length
    };

    this.nextPack = function() {
        var idx = ($.inArray(currentPackId, packOrder) + 1) % packOrder.length; //Find the index of the next pack
        var key = packOrder[idx]; //Find the key
        return packsDB[key]; //Get it
    };

    this.prevPack = function() {
        var idx = ($.inArray(currentPackId, packOrder) - 1); //Find the index of the next pack
        var key = packOrder[(idx < 0 ? packOrder.length + idx : idx)]; //Find the key
        return packsDB[key]; //Get it
    };

    this.getUrlParameterByName = function(name) {
        name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
        var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
            results = regex.exec(location.search);
        return results == null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
    }

    this.stickerAddedToCanvas = function(stickerId) {
      var new_value,
          prop,
          stickerProps = this.getStickerById(stickerId).properties
      for(prop in stickerPropsList){
        if(!stickerProps[prop]){
          continue;
        }
        stickerPropsList[prop].node=stickerPropsList[prop].node || $(stickerPropsList[prop].node_id);
        new_value = (+stickerPropsList[prop].node.text()) +(+stickerProps[prop]);
        stickerPropsList[prop].node.text(new_value);
      }
    }

    this.stickerRemovedFromCanvas = function(stickerId) {
      var new_value,
        prop,
        stickerProps = this.getStickerById(stickerId).properties
      for(prop in stickerPropsList){
        if(!stickerProps[prop]){
          continue;
        }
        stickerPropsList[prop].node=stickerPropsList[prop].node || $(stickerPropsList[prop].node_id);
        new_value = (+stickerPropsList[prop].node.text())-(+stickerProps[prop]);
        stickerPropsList[prop].node.text(new_value);
      }
    }
};

if (typeof exports != 'undefined') {
    exports.psUtils = psUtils;
}