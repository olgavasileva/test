"use strict";
var psNetwork = function() {
    /**
     * Singleton constructor
     */
    if (psNetwork.prototype._instance) {
        return psNetwork.prototype._instance;
    }
    psNetwork.prototype._instance = this;

    //========================================
    // Public interface
    //========================================

    this.getStudioConfig = getStudioConfig;
    this.getStickerPacks = getStickerPacks;
    this.getStickers = getStickers;
    this.saveAvatar = saveAvatar;

    this.saveCurrentScene = function(scene_data) {
        return saveScene(PS_SCENE_ID, scene_data, PS_STUDIO_ID);
    }

    this.enterContest = function(contest_id) {
        return addToGallery(PS_SCENE_ID, contest_id);
    }

    this.getScaledScene = function(scene_id, callback) {
        var params = {
            canvas_height: $("#ps-canvas").height(),
            canvas_width: $("#ps-canvas").width()
        };
        return $.ajax({
            url: API_URL + "/scenes/get/" + scene_id,
            //dataType: 'jsonp',
            data: params,
            type: 'GET',
            success: function(data) {
                callback(data);
            }
        });
    }

    /*
    this.loadAllData = function()
    {
    	var dfdResult = $.Deferred();
    	var studio_id = PS_STUDIO_ID;
    	var stickers = [];
    	var studio = {};
    	var menus = [];
    	var progressBar = showProgressbar();

    	getStudioWithData( studio_id ).done(function( _studio ){
    		progressBar.progressbar( "option", "max", 0 );
    		progressBar.progressbar( "value", 0 );

			menus = _studio.menus;
    		_studio.menus = null;
    		studio = _studio;

    		_.each( menus, function( _menu ){
    			_.each( _menu.sticker_packs, function( _pack ){
					_.each( _pack.stickers, function( _sticker ){
    					_sticker._menu_id = _menu.id;
    					_sticker._pack_id = _pack.id;
	    				stickers.push( _sticker );
					});
    			});
    		});

			dfdResult.resolve( studio, menus, stickers );

    	}).fail(function(){ // getMenuStructure
    		dfdResult.reject();
    		alert('Scene loading failed. Please refresh the page to try again.');
    	});

    	return dfdResult;
    }
    */

    //========================================
    // Private methods
    //========================================

    var API_URL = "/";

    function getStickerPacks(studio_id) {
        var dfd = $.Deferred();
        $.ajax(API_URL + "v/2.0/studios/" + studio_id + "/sticker_packs.json", {
            chache: false,
            data: {
                canvas_width: $("#ps-canvas").width(),
                canvas_height: $("#ps-canvas").height()
            },
            //crossDomain: true,
            //dataType: 'jsonp',
            type: 'POST'
        }).done(function(data) {
            if (data.sticker_packs != null) {
                dfd.resolve(data.sticker_packs);
            } else {
                dfd.reject();
            }
        })
            .fail(function(data) {
                dfd.reject();
            });
        return dfd;
    }

    function getStickers(studio_id, sticker_pack_id) {
        var dfd = $.Deferred();
        $.ajax(API_URL + "v/2.0/studios/" + studio_id + "/sticker_packs/" + sticker_pack_id + "/stickers.json", {
            chache: false,
            data: {
                canvas_width: $("#ps-canvas").width(),
                canvas_height: $("#ps-canvas").height()
            },
            //crossDomain: true,
            //dataType: 'jsonp',
            type: 'POST'
        }).done(function(data) {
            if (data.stickers != null || data.backgrounds != null) {
                var stickers = {};
                if (data.stickers != null){
                  stickers['stickers'] = data.stickers.map(function(sticker){
                    sticker.pack_id=sticker_pack_id;
                    return sticker;
                  });
                }

                if (data.backgrounds != null){
                  stickers['backgrounds'] = data.backgrounds.map(function(sticker){
                    sticker.pack_id=sticker_pack_id;
                    return sticker;
                  });
                }
                dfd.resolve(stickers);
            } else {
                dfd.reject();
            }
        })
            .fail(function(data) {
                dfd.reject();
            });
        return dfd;
    }

    function getStudioConfig(studio_id) {
        var dfd = $.Deferred();
        $.ajax(API_URL + "v/2.0/studios/" + studio_id + ".json", {
            chache: false,
            //crossDomain: true,
            //dataType: 'jsonp',
            type: 'POST'
        }).done(function(data) {
            if (data.studio != null) {
                dfd.resolve(data.studio);
            } else {
                dfd.reject();
            }
        })
            .fail(function(data) {
                dfd.reject();
            });
        return dfd;
    }

    function showProgressbar() {
        var overlay = '<div class="ui-widget-overlay ui-front"></div>';
        var bar = '<div class="ps-progress-bar"><div class="ps-progress-label">Loading Scene...</div></div>';
        var dialog = $('<div/>').addClass('ps-network-progress ps-ui').html(overlay + bar);
        $('body').append(dialog);

        dialog.css({
            left: $('#ps-frame').offset().left + $('#ps-frame').width() / 2 - dialog.width() / 2,
            top: $('#ps-frame').offset().top + $("#ps-frame").height() / 2 - dialog.height() / 2
        });

        var progressbar = $(".ps-progress-bar", dialog);
        var progressLabel = $(".ps-progress-label", dialog);

        progressbar.progressbar({
            value: false,
            change: function() {
                var val = progressbar.progressbar("value");
                var max = progressbar.progressbar("option", "max");
                if (val == 0) {
                    progressLabel.text("Loading Stickers...");
                } else {
                    progressLabel.text(Math.round(val / max * 100) + "%");
                }
            },
            complete: function() {
                progressbar.progressbar("destroy");
                dialog.remove();
            }
        });

        return progressbar;
    }

    function saveScene(scene_id, scene_data, studio_id) {
        var params = {
            scene: scene_data,
            canvas_height: $("#ps-canvas").height(),
            canvas_width: $("#ps-canvas").width(),
            question_id: QUESTION_ID,
            third_party_id: THIRD_PARTY_ID
        };
        if (scene_id != null && scene_id > 0) {
            params.id = scene_id;
        }
        if (studio_id != null) {
            params.studio = studio_id;
        }
        return $.ajax({
            url: API_URL + "/surveys/" + SURVEY_ID + "/studio_respond",
            beforeSend: function(xhr) {
                xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
            },
            //dataType: 'jsonp',
            data: params,
            type: 'POST',
            success: function(data) {
                PS_SCENE_ID = data.id;
                PS_DETAILS_URL = data.detailsUrl;
            }
        });
    }

    function addToGallery(scene_id, gallery_id) {
        var params = {
            gallery: gallery_id
        };
        return $.ajax({
            url: API_URL + "/scenes/add_to_gallery/" + scene_id.toString(),
            beforeSend: function(xhr) {
                xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
            },
            //dataType: 'jsonp',
            data: params,
            type: 'POST'
        });
    }

    function saveAvatar(scene_id, left, top) {
        var params = {
            scene_id: scene_id,
            left: left,
            top: top
        };

        return $.ajax({
            url: API_URL + "/avatar/save",
            beforeSend: function(xhr) {
                xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
            },
            data: params,
            type: 'POST'
        });
    }

};