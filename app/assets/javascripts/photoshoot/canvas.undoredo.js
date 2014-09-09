"use strict";
$(function() {

    var history = [];
    var historySize = 10;
    var cursorPos = 0;
    var btnUndo = $("#ps-undo");
    var btnRedo = $("#ps-redo");

    $(document).bind("ps.canvas.undoredo.addToHistory", addToHistory);
    $(document).bind("ps.canvas.undoredo.clearHistory", clearHistory);
    $(document).bind('ui.clearAll.after', addToHistory);

    $(document).bind("ps.canvas.init.after", function() {
        var canvas = psCanvas().getContext();
        addToHistory();
        canvas.on({
            'object:modified': addToHistory
        });
    });

    btnUndo.click(function() {
        if ($(this).hasClass('ps-btn-disabled')) {
            return false;
        }
        cursorPos--;
        psCanvas().loadScene(history[cursorPos]['canvas'], function() {
            psCanvas().getContext().renderAll();
        });
        updateNutrition(history[cursorPos]);
        updateButtons();
        $(document).trigger("ps.canvas.stickermenu.hideContextMenu");
        return false;
    });

    btnRedo.click(function() {
        if ($(this).hasClass('ps-btn-disabled')) {
            return false;
        }
        cursorPos++;
        psCanvas().loadScene(history[cursorPos]['canvas'], function() {
            psCanvas().getContext().renderAll();
        });
        updateNutrition(history[cursorPos]);
        updateButtons();
        $(document).trigger("ps.canvas.stickermenu.hideContextMenu");
        return false;
    });

    function addToHistory() {
        var dfd = new $.Deferred();
        dfd.done(function(data) {
            if (cursorPos < history.length - 1) {
                history = history.splice(cursorPos, history.length - cursorPos - 1)
            }

            if (history[cursorPos] && history[cursorPos]['canvas'] == data) {
                return false;
            }

            if (history.length == historySize) {
                history.shift();
            }

            cursorPos = history.push({
                'canvas': data,
                'calories': $("#calorie-counter").text(),
                'protein': $("#protein-counter").text(),
                'sugar': $("#sugar-counter").text(),
                'carbohydrates': $("#carbohydrates-counter").text(),
                'fat': $("#total-fat").text(),
                'satfat': $('#sat-fat').text(),
                'cholesterolcounter': $('#cholesterol-counter').text(),
                'sodiumcounter': $('#sodium-counter').text(),
                'fibercounter': $('#fiber-counter').text(),
                'caloriesfromfat': $('#calories-from-fat').text()
            }) - 1;
            updateButtons();
        });
        $(document).trigger("ps.canvas.serializer.serialize", [dfd]);
    }

    function clearHistory() {
        history = [];
        cursorPos = 0;
        addToHistory();
        updateButtons();
    }

    function updateButtons() {
        if (cursorPos < history.length - 1) {
            btnRedo.removeClass('ps-btn-disabled');
        } else {
            btnRedo.addClass('ps-btn-disabled');
        }
        if (cursorPos == 0) {
            btnUndo.addClass('ps-btn-disabled');
        } else {
            btnUndo.removeClass('ps-btn-disabled');
        }
    }

    function updateNutrition(data) {
        $("#calorie-counter").text(data['calories']);
        $("#protein-counter").text(data['protein']);
        $("#sugar-counter").text(data['sugar']);
        $("#carbohydrates-counter").text(data['carbohydrates']);
        $("#total-fat").text(data['fat']);
        $("#sat-fat").text(data['satfat']);
        $("#cholesterol-counter").text(data['cholesterolcounter']);
        $("#sodium-counter").text(data['sodiumcounter']);
        $("#fiber-counter").text(data['fibercounter']);
        $("#calories-from-fat").text(data['caloriesfromfat']);
    }
});