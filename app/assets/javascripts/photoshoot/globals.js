(function() {
    /* define size constants */
    PS_MENU_WIDTH = 278; // PS_ITEMS_MENU_CELL_WIDTH + (PS_ITEMS_MENU_CELL_MARGIN * 6 /* margins */))
    PS_MENU_SCROLL_WIDTH = 18;
    PS_OTHERS_HEIGHT = 0; // total vertical space occupied by other elements
    PS_HEADER_HEIGHT = 0;
    PS_MIN_CANVAS_WIDTH = 720;
    PS_MAX_CANVAS_WIDTH = 2048;
    PS_MIN_CANVAS_HEIGHT = 495;
    PS_MAX_CANVAS_HEIGHT = 1408;
    PS_ITEMS_MENU_CELL_WIDTH = 118;
    PS_ITEMS_MENU_CELL_HEIGHT = 118;
    PS_ITEMS_MENU_CELL_MARGIN = 10;
    PS_DIRS_MENU_ICON_WIDTH = 100;
    PS_DIRS_MENU_ICON_HEIGHT = 100;
    PS_BASE_WIDTH = 2048;
    PS_BASE_HEIGHT = 1408;
    PS_STUDIO_ID = 0;
    PS_STUDIO_NAME = 0;
    PS_SCENE_ID = 0;
    PS_DETAILS_URL = "";
    PS_CONTEST_ID = 0;
    PS_DEBUG_MODE_ON = false;
    PS_LOGGED_IN = 0;
    PS_SAVE_MODAL_WIDTH = 600;
    SURVEY_ID = 0;
    QUESTION_ID = 0;
    THIRD_PARTY_ID = 0;
})();

$(function() {
    $(document).bind("ps.bootstrap.initializing", function() {
        if ($("#photoshootinfo").length == 1 && $("#studio-wrapper").length == 1) {
            var data = $("#photoshootinfo").data();

            PS_OTHERS_HEIGHT = $("#studio-wrapper").offset().top + 2; // total vertical space occupied by other elements
            PS_HEADER_HEIGHT = $('#ps-breadcrumbs').outerHeight();

            PS_STUDIO_ID = data.studioId;
            PS_STUDIO_NAME = data.studioName;
            PS_LOGGED_IN = data.loggedIn;
            QUESTION_ID = data.questionId;

            if ($("#sceneinfo").length > 0) {
                var sceneData = $("#sceneinfo").data();
                PS_SCENE_ID = sceneData.sceneId;
                PS_DETAILS_URL = sceneData.shareLink;
            }
        }
    })
});