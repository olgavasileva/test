"use strict";
var psUI = function() {
    /**
     * Private vars
     */
    var swiperMenu;
    var elMenuId = "#pack-wrapper";
    var elCrumbsId = "#ps-breadcrumbs";
    var elMenuItemPopup = "#ps-menu-popup";
    var isMenuMovedNow = false;

    /**
     * Singleton constructor
     */
    if (psUI.prototype._instance) {
        return psUI.prototype._instance;
    }
    psUI.prototype._instance = this;

    //========================================
    // Private methods
    //========================================

    /**
     * Init
     */
    (function() {
        $("footer.global").hide();

        $("#ps-save").click(function() {
            // saveScene(PS_LOGGED_IN);
            saveSceneForDemo(PS_LOGGED_IN);
            return false;
        });

        $("#ps-enter-contest").click(function() {
            $("#enter-contest-dialog").dialog("open");
            return false;
        });

        $("#ps-enter-contest-save").click(function() {
            $("#enter-contest-dialog").dialog("close");
            var preloader = showPreloader("<p><b>Best of luck fashionista!</b></p><p>We are submitting to the contest</p>", 'ps-contest-enter-overlay');

            var ret = new $.Deferred();
            ret.done(function(scene) {
                psNetwork().enterContest(PS_CONTEST_ID).complete(function() {
                    preloader.remove();
                    window.location = '/galleries/' + PS_CONTEST_ID.toString();
                });
            });
            $(document).trigger("ps.canvas.serializer.serialize", [ret]);
            return false;
        });

        $('.prev-pack').on('click', function(e) {
            renderPackDetails(psUtils().nextPack());
        });

        $('.next-pack').on('click', function(e) {
            renderPackDetails(psUtils().prevPack());
        });

        $('#browse-packs-drop').click(function() {
            renderPackDetails();
        });

        $('#all-packs-drop').click(function() {
            renderPackList();
        });

        $("#ps-not-ready").click(function() {
            $("#enter-contest-dialog").dialog("close");
            return false;
        });

        $("#ps-help").click(showHelp);

        $("#ps-clear-all").click(clearAll);

        $(document).on('click', '.sticker-pack-wrapper', function(e) {
            e.preventDefault();
            var data = $(e.currentTarget).data();
            renderPackDetails(psUtils().getPackByID(data.packId));
        });


    }());

    function drawerUI(handle, parent, assetContainer) {

        // PRIVATE
        var drawerHandle = !handle ? '.drawer-handle' : handle,
            parentContainer = !parent ? '.drawer' : parent,
            assetContainer = !assetContainer ? '#asset-wrapper' : assetContainer,
            openedClass = 'active',
            openedClasses = 'active',
            closedClasses = 'inactive';


        var controller = function(e) {
            var $parent = $(e.target).parents(parentContainer),
                isOpen = $parent.hasClass(openedClass); // TRUE or FALSE

            if (isOpen) {
                view.close();

            } else {
                view.open();
            }
        };

        var view = {
            close: function() {
                //var assetContW = $(assetContainer).width();
                $(parentContainer)
                    .addClass(closedClasses)
                    .removeClass(openedClasses);
            },
            open: function() {
                $(parentContainer)
                    .addClass(openedClasses)
                    .removeClass(closedClasses);
            }
        };

        function bindEvents() {
            $(drawerHandle).click(function(e) {
                controller(e);
            });
        }

        return {
            init: function() {
                bindEvents();
            },
            open: function() {
                view.open();
            },
            close: function() {
                view.close();
            }
        }
    }

    function saveSceneForDemo(logged_in) {
        var preloader_text;
        if (logged_in)
            preloader_text = "Saving to<br/>your gallery";
        else
            preloader_text = "Please log in";

        var preloader = showPreloader(preloader_text);

        var ret = new $.Deferred();
        ret.done(function(scene) {
            if (JSON.parse(scene).objects.length == 0) {
                preloader.remove();
                alert("Show us your favorite breakfast!");
            } else {
                preloader.remove();
                window.location = '/gallery';
            }
        });
        $(document).trigger("ps.canvas.serializer.serialize", [ret]);
        return false;
    }

    function saveScene(logged_in) {
        var preloader_text;
        if (logged_in)
            preloader_text = "Saving to<br/>your gallery";
        else
            preloader_text = "Please log in";

        var preloader = showPreloader(preloader_text);

        var ret = new $.Deferred();
        ret.done(function(scene) {
            if (JSON.parse(scene).objects.length == 0) {
                preloader.remove();
                alert("Show us your favorite breakfast!");
                return;
            }
            psNetwork().saveCurrentScene(scene).complete(function() {
                preloader.remove();
                if (logged_in)
                    $("#thanku-dialog").dialog("open");
                else {
                    //Need to take out any added parameters and carry them through
                    var params = window.location.href.split("?")[1],
                        paramString = "";
                    if (typeof params == 'string') {
                        paramString = "?" + params
                    }
                    window.location = '/session/new?return_to=http://' + window.location.host + window.location.pathname + "/" + PS_SCENE_ID + paramString;
                }
                $('.ui-dialog :button, .ui-dialog a').blur();
            });
        });
        $(document).trigger("ps.canvas.serializer.serialize", [ret]);
        return false;
    }

    function showHelp() {
        var body = $('body');
        var ps_frame = $('#studio-wrapper');
        ps_frame.addClass('help-active');
        body.append('<div class="overlay"></div>');

        body.find(".overlay").css({
            'background': 'rgba(0, 0, 0, .5)',
            'width': '100%', //ps_frame.width(),
            'height': '100%', //ps_frame.height(),
            'position': 'absolute',
            'top': 0,
            'left': 0,
            'z-index': 100
        });

        $(".overlay, .help").click(function() {
            ps_frame.removeClass('help-active');
            $('.overlay').remove();
        });

        return false;
    }

    function clearAll() {
        $('#clear-scene-modal').modal('show');
        return false;
    }

    $('#clear-scene-modal button#clear-all').on('click', function() {
        $(document).trigger('ui.clearAll.before');
        psCanvas().getContext().backgroundImage = 0;
        psCanvas().getContext().clear();
        $('.nutrition-value span').text("0");
        $(document).trigger('ui.clearAll.after');
    });


    /**
     * Show loading dialog inside application frame
     */
    function showPreloader(text, className, width, height, top, left) {
        var ps_frame = $('body');
        var cn = className || 'ps-saving-overlay';
        //        var w = width || ps_frame.width();
        //        var h = height || ps_frame.height();
        var y = top || ps_frame.offset().top + 1; // 1 is border width
        //        var x = left || ps_frame.offset().left + 1; // 1 is border width

        var wnd = $('<div>').addClass(cn).css({
            'width': '100%',
            'height': '100%', //$(window).height() - ps_frame.offset().top - 2,
            'top': 0, //y,
            'left': 0
        }).append(
            $('<div>').append(
                $('<div>').html(text)
            )
        );

        ps_frame.append(wnd);
        return wnd;
    }

    /**
     *
     */
    function resizeImageForMenu(type, img_width, img_height, max_width, max_height) {
        var aspectRatio = Math.max(img_height, img_width) / Math.min(img_height, img_width);
        var bgH = max_height;
        var bgW = max_width;
        var bgPosY = 0;
        var bgPosX = 0;

        switch (type) {
            case "Background":
                bgW = bgH * aspectRatio;
                bgPosX = (bgH - bgW) / 2;
                break;

            case "ModelSticker":
                var bgH = bgW * aspectRatio;
                break;

                //			case "Sticker":
            default:
                if (img_width > img_height) {
                    var bgH = bgW / aspectRatio;
                    var bgPosY = (bgW - bgH) / 2;
                } else {
                    var bgW = bgH / aspectRatio;
                    var bgPosX = (bgH - bgW) / 2;
                }
                break;
        }

        return {
            width: Math.round(bgW),
            height: Math.round(bgH),
            posX: Math.round(bgPosX),
            posY: Math.round(bgPosY)
        }
    }

    /**
     *
     */
    //  function hideMenuItemPopup(){
    //    $(elMenuItemPopup).css('left', '-1000px');
    //  }

    function renderPackList() {
        $(document).trigger('ui.createPackList.before');
        var source = $('#sticker-pack-list').html();
        var template = Handlebars.compile(source);
        var assetTitle = $('#asset-title');
        $(elMenuId).html(template({
            sticker_packs: psUtils().getPacks()
        }));

        assetTitle.find('.pack-browser-control').hide();
        assetTitle.find('.title-text').html('All Packs');

        $(document).trigger('ui.createPackList.after');
    }

    function renderPackDetails(pack) {
        $(document).trigger('ui.createStickerItems.before');
        var source = $('#sticker-pack-detail').html();
        var template = Handlebars.compile(source);
        var assetTitle = $('#asset-title');
        var totalPacks = psUtils().countPacks();

        if (typeof pack == 'undefined')
            pack = psUtils().getCurrentPack();

        psUtils().setCurrentPackId(pack.id);

        $(elMenuId).html(template({
            sticker_pack: pack
        }));
        assetTitle.find('.pack-browser-control').show();
        assetTitle.find('.title-text').html((pack.sort_order + 1) + ' of ' + totalPacks + ' Packs');

        enableDraggableObj();

        $(document).trigger('ui.createStickerItems.after', [elMenuId]);
        // Register a page view in Google Analytics
        //dataLayer.push({'event': 'scrollPage','pagePath' : window.location.pathname + "?sticker_pack=" + pack.id});
    }

    function enableDraggableObj() {
        var delayLength = Modernizr.touch ? 300 : 0;

        $(elMenuId).find(".stickable").draggable({
            scroll: true,
            //axis: "x",
            //distance: 40,
            delay: delayLength,
            helper: function() {
                var data = $(this).find('img').data();
                var canvas = psCanvas();
                var sticker = psUtils().getStickerById(data.id);
                var scaled = canvas.scaleProportionally(sticker);

                var ghost = $('<div/>').css({
                    width: scaled.width,
                    height: scaled.height,
                    'z-index': 20,
                    background: "url(" + data.src + ")"
                }).css('background-size', scaled.width + "px " + scaled.height + "px");

                var ctx = canvas.getContext();
                var obj = ctx.getActiveObject() || ctx.getActiveGroup();
                if (obj != null) {
                    var angle = obj.angle;
                    ghost.css("-webkit-transform", "rotate(" + angle + "deg)");
                    ghost.css("-moz-transform", "rotate(" + angle + "deg)");
                    ghost.css("-ms-transform", "rotate(" + angle + "deg)");
                    ghost.css("-o-transform", "rotate(" + angle + "deg)");
                    ghost.css("transform", "rotate(" + angle + "deg)");
                }
                ghost.hide();
                return ghost;
            },
            zIndex: 99999,
            appendTo: '#studio-wrapper',
            containment: "#studio-wrapper",
            start: function(e, ui) {
                setTimeout(function() {
                    ui.helper.show();
                }, 100);
            },
            drag: function(e, ui) {
                //        console.log(e, ui);
                //        console.log("top " + ui.position.top);
                //        console.log("offset " + ui.offset.top);
                ui.position.top = ui.offset.top - $("#studio-wrapper").offset().top;
            }
        }).on('click', function() {
            var data = $(this).find('img').data();
            if (data.type == 'Background') {
                psCanvas().placeBackground(data);
            }
            return false;
        });
    }


    //========================================
    // Public methods
    //========================================
    this.drawer = drawerUI;
    this.resizeImageForMenu = resizeImageForMenu;
    this.showPreloader = showPreloader;
    this.renderPackList = renderPackList;
    this.renderPackDetails = renderPackDetails;


    this.startOver = function() {
        $("#thanku-dialog").dialog("close");
        psCanvas().getContext().clear();
        PS_SCENE_ID = 0;
    };
    this.enterContest = function() {
        $("#thanku-dialog").dialog("close");
        $("#enter-contest-dialog").dialog("open");
    };
    this.addToGallery = function() {
        $("#thanku-dialog").dialog("close");
        var preloader = showPreloader("<p>We are submitting to the gallery</p>", 'ps-contest-enter-overlay');

        var ret = new $.Deferred();
        ret.done(function(scene) {
            psNetwork().enterContest(PS_CONTEST_ID).complete(function() {
                preloader.remove();
                window.location = '/galleries/' + PS_CONTEST_ID.toString();
            });
        });
        $(document).trigger("ps.canvas.serializer.serialize", [ret]);
        return false;
    }
    this.share = function() {
        $("#thanku-dialog").dialog("close");
        renderTemplate("share_form", {
            "itemId": PS_SCENE_ID,
            "itemType": "scene",
            "shareUrl": FP_APP_DOMAIN + "/scenes/share/" + PS_SCENE_ID + ".json",
            "detailsUrl": PS_DETAILS_URL,
            "studioName": PS_STUDIO_NAME
        }, function(content) {
            $("#share-modal div.modal-body").html(content);
            shareForm().initialize();
            $("#share-modal").modal("show");
        });
    };
    this.saveSceneAfterLogin = function() {
        saveScene(true);
    };
    this.setAsAvatar = function() {
        $("#thanku-dialog").dialog("close");

        var tool = $('<div>').addClass('ps-avatar-tool').append(
            $('<div>').addClass('ps-avatar-tool-header').append(
                $('<span>').html('Set as Avatar')
            ),
            $('<div>').addClass('ps-avatar-tool-buttons'),
            $('<div>').addClass('ps-avatar-tool-frame')
        );

        var ps_frame = $('#studio-wrapper');

        var overlay = $('<div>').css({
            'background': 'rgba(0, 0, 0, .1)',
            'width': ps_frame.width(),
            'height': ps_frame.height(),
            'position': 'absolute',
            'top': ps_frame.offset().top + 1, // + border width
            'left': ps_frame.offset().left + 1, // + border width
            'z-index': 100
        });
        $(window).on('resize.setAsAvatarOverlay', function() {
            var ps_frame = $('#studio-wrapper');
            overlay.css({
                'width': ps_frame.width(),
                'height': ps_frame.height(),
                'top': ps_frame.offset().top + 1, // + border width
                'left': ps_frame.offset().left + 1 // + border width
            });
        });

        ps_frame.append(overlay);

        var btnSave = $('<button>').addClass('btn ps-btn-yellow').text('Save').click(function() {
            var canvasOffset = $('#ps-canvas').offset();
            var avatarOffset = tool.find('.ps-avatar-tool-frame').offset();
            var left = avatarOffset.left - canvasOffset.left + 13; // 13: border + padding
            var top = avatarOffset.top - canvasOffset.top + 10; // 10: padding
            left = Math.round(left);
            top = Math.round(top);

            tool.remove();
            $(window).off('click.setAsAvatarOverlay');
            overlay.remove();
            btnSave.remove();
            btnCancel.remove();

            var preloader = showPreloader("Saving avatar");
            psNetwork().saveAvatar(PS_SCENE_ID, left, top).complete(function() {
                preloader.remove();
            });
            return false;
        });

        var btnCancel = $('<button>').addClass('btn btn-gary-dark ps-btn-gray').text('Cancel').css({

        }).click(function() {
            tool.remove();
            $(window).off('click.setAsAvatarOverlay');
            overlay.remove();
            btnSave.remove();
            btnCancel.remove();
            return false;
        });

        tool.find('.ps-avatar-tool-buttons').append(btnSave, btnCancel);

        var ps_canvas = $('#ps-canvas');

        tool.appendTo('body');
        tool.draggable({
            containment: "#ps-canvas",
            scroll: false,
            start: function(event, ui) {
                var isWebkit = 'webkitRequestAnimationFrame' in window;
                if (!isWebkit) {
                    ui.position.top -= $(window).scrollTop();
                }
            },
            drag: function(event, ui) {
                var isWebkit = 'webkitRequestAnimationFrame' in window;
                if (!isWebkit) {
                    ui.position.top -= $(window).scrollTop();
                }
            }
        });
        tool.css({
            'top': ps_canvas.height() / 2 + ps_canvas.offset().top - tool.height() / 2,
            'left': ps_canvas.width() / 2 + ps_canvas.offset().left - tool.width() / 2
        });
    }
    this.studioActionLink = function(id) {
        window.open('/studio/link/' + id + '?scene_id=' + PS_SCENE_ID);
    }
};