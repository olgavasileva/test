$('document').ready(function() {
    $(document).trigger('ps.bootstrap.initializing');

    if (PS_STUDIO_ID == 0)
        return;

    var ui = new psUI();
    var utils = new psUtils();
    var canvas = new psCanvas();
    var network = new psNetwork();
    var preloader = ui.showPreloader("Loading your awesome scene");

    //UI init
    ui.drawer().init();
    setupDialogs();


    //    $('#pack-drawer').on('mousemove', function(event){
    //       event.preventDefault();
    //    });

    var loadingStudio = network.getStudioConfig(PS_STUDIO_ID);
    var loadingStickerPacks = network.getStickerPacks(PS_STUDIO_ID);

    $(document).on('studioLoaded', function() {
        studioLoaded();
    });

    $.when(loadingStudio, loadingStickerPacks).done(function(studio, packs) {
        setupStudio(studio);

        var requests = [];

        _.each(packs, function(pack) {
            pack.stickers = [];
            pack.backgrounds = [];
            requests.push(network.getStickers(PS_STUDIO_ID, pack.id).done(function(_stickers) {
                _.each(_stickers, function(stickers, sticker_type) {

                    pack[sticker_type] = stickers;

                    if (stickers != null)
                        utils.setStickers(stickers);
                });
            }));
        });
        utils.setPacks(packs);
        $.when.apply($, requests).then(function() {
            // stickers loading complete
            ui.renderPackDetails(packs[0]);
            $(document).trigger('studioLoaded');
        });
    });

    // handling resizing

    //	$(window).resize(function(e)
    //	{
    function _calculateCanvasHeight() {
        var v = $(window).height() - PS_HEADER_HEIGHT - PS_OTHERS_HEIGHT;
        return Math.min(PS_MAX_CANVAS_HEIGHT, Math.max(v, PS_MIN_CANVAS_HEIGHT));
    }

    function _calculateCanvasWidth() {
        return Math.ceil(_calculateCanvasHeight() * (720 / 495));
        //      var v = Math.ceil( _calculateCanvasHeight() * (4/3) );
        //			return Math.min( PS_MAX_CANVAS_WIDTH, Math.max( v, PS_MIN_CANVAS_WIDTH ));
    }

    var ch = _calculateCanvasHeight();
    var cw = _calculateCanvasWidth();

    $("#pack-drawer").css({
        top: 0 + PS_HEADER_HEIGHT,
        height: ch
    });
    $("#ps-desktop").css({
        width: cw,
        height: ch,
        minHeight: ch
    });
    canvas.setDimensions(cw, ch);
    $("#pack-wrapper").css('height', ch - 31);
    //	});

    if (utils.getUrlParameterByName('debug') == 'techisland') {
        PS_DEBUG_MODE_ON = true;
    }

    //	$(window).trigger('resize');
    $(document).trigger('ps.bootstrap.initialized');

    /**
     *
     */
    function setupDialogs() {
        $("#flaunt-dialog").dialog((new psUtils()).getDialogConfig({
            width: 401,
            dialogClass: 'ps-flaunt-dialog'
        }));

        $("#thanku-dialog").dialog((new psUtils()).getDialogConfig({
            width: PS_SAVE_MODAL_WIDTH,
            dialogClass: 'ps-thanku-dialog'
        }));

        $("#enter-contest-dialog").dialog((new psUtils()).getDialogConfig({
            width: 450,
            dialogClass: 'ps-enter-contest-dialog'
        }));

        $("#avatar-dialog").dialog((new psUtils()).getDialogConfig({
            width: 535,
            dialogClass: 'ps-avatar-dialog'
        }));

        $("#clear-scene-dialog").dialog((new psUtils()).getDialogConfig({
            width: 330,
            dialogClass: 'ps-clear-scene-dialog'
        }));

        $("#welcome-dialog").dialog((new psUtils()).getDialogConfig({
            width: 600,
            dialogClass: 'ps-welcome-dialog'
        }));
    }

    /**
     *
     */
    function setupStudio(studio) {

        //		$('#ps-header').html( studio.html_header );

        // set studio title & icon
        var setupForContest = utils.getUrlParameterByName('contest_id') ? true : false;

        if (setupForContest) {
            // TODO: pass through the contest details in the functions
            setTitle();
            setIcon();
        } else {
            setTitle();
            setIcon();
        }


        function setTitle(title) {
            var $studioTitle = $('#current-studio-name'),
                displayName = !title ? studio.display_name : title;
            $studioTitle.html(displayName);
        }

        function setIcon(url) {
            var $studioIconWrapper = $('#current-studio-icon'),
                imgURL = !url ? studio.icon_url : url,
                imgTag = '<img src="' + imgURL + '">';
            $studioIconWrapper.html(imgTag);
        }

        // show welcome message
        if ($.cookie('ps_studio_config_' + studio.permalink) == null) {
            $.cookie('ps_studio_config_' + studio.permalink, 'true', {
                expires: 36500,
                path: '/'
            });

            // show welcome dialog
            var dlg = $('#welcome-dialog');
            dlg.find('h1').html(studio.title);
            dlg.find('p > span').html(studio.description);
            dlg.find('p > button').html(studio.call_to_action).click(function() {
                dlg.dialog("close");
            });
            dlg.dialog('option', 'title', studio.title_bar_title);
            dlg.dialog("open");
            $('.ui-dialog :button, .ui-dialog a').blur();
        }
    }

    function studioLoaded() {
        preloader.remove();
        ui.drawer().open();
    }
});