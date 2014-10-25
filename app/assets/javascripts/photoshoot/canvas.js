"use strict";
var psCanvas = function() {
    /**
     * Singleton constructor
     */
    if (psCanvas.prototype._instance) {
        return psCanvas.prototype._instance;
    }
    psCanvas.prototype._instance = this;

    //========================================
    // Public interface
    //========================================

    this.isSomeObjectSelected = isSomeObjectSelected;
    this.scaleProportionally = scaleProportionally;
    this.placeSticker = placeSticker;
    this.placeBackground = placeBackground;
    this.setDimensions = setDimensions;
    this.getHeight = getHeight;
    this.getWidth = getWidth;
    this.moveForward = moveForward;
    this.moveBackward = moveBackward;
    this.flip = flip;
    this.group = group;
    this.ungroup = ungroup;
    this.remove = remove;
    this.loadScene = loadScene;
    this.toJSON = toJSON;
    this.hasMirrorableStickers = hasMirrorableStickers;
    this.getInstanceOfFabricJS = getInstanceOfFabricJS;
    this.getContext = getInstanceOfFabricJS;

    //========================================
    // Private methods
    //========================================

    var canvas;

    /**
     * Init
     */
    ;
    (function(self) {
        $(document).trigger('ps.canvas.init.before');

        canvas = new fabric.Canvas('ps-canvas');

        $('.upper-canvas').droppable({
            /* activeClass: "ui-state-default", */
            /* hoverClass: "ui-state-hover", */
            drop: function(e, ui) {
                //	      		if( psUI().isMenuMovedNow() ){
                //	      			return;
                //	      		}
                var data = ui.draggable.find('img').data();

                switch (data.type) {
                    case 'Background':
                        self.placeBackground(data);
                        break;
                    default:
                        var x = Math.max(ui.offset.left - $(this).offset().left, 0);
                        var y = Math.max(ui.offset.top - $(this).offset().top, 0);
                        self.placeSticker(data, x, y);
                        psUtils().stickerAddedToCanvas(data.id);
                        break;
                }
            }
        });

        $('.upper-canvas').on('mouseenter mouseleave', function() {
            if (window.getSelection) {
                window.getSelection().removeAllRanges();
            }
        });

        $(document).trigger('ps.canvas.init.after');
    }(this));

    /**
     *
     */
    function getInstanceOfFabricJS() {
        return canvas;
    }

    /**
     *
     */
    function setDimensions(w, h) {
        canvas.setDimensions({
            width: w,
            height: h
        });
    }

    function getHeight() {
        return canvas.height;
    }

    function getWidth() {
        return canvas.width;
    }

    /**
     *
     */
    function placeBackground(data) {
        var d=psUtils().getStickerById(data.id);

      var fImage=new fabric.Image(d.imageObject, {
        originX: 'left',
        originY: 'top',
        left: 0,
        top: 0
      });
      canvas.setBackgroundImage(fImage, function() {
          canvas.renderAll();
          $(document).trigger("ps.canvas.undoredo.addToHistory");
      });

    }

    /**
     *
     */
    function placeSticker(data, x, y) {
        var sticker = psUtils().getStickerById(data.id);
        var scaled = this.scaleProportionally(sticker);

        fabric.Image.fromURL(data.src, function(oImg) {
            oImg.set("psOrigWidth", data.width);
            oImg.set("psOrigHeight", data.height);
            oImg.set("psType", data.type);
            oImg.set("psItemId", data.id);
            oImg.set("width", scaled.width);
            oImg.set("height", scaled.height);
            oImg.set("left", x + Math.round(scaled.width / 2));
            oImg.set("top", y + Math.round(scaled.height / 2));

            // keep the same rotation angle as a target object
            if (sticker.properties.fit_to_model == 1) {
                var activeObject = canvas.getActiveObject() || canvas.getActiveGroup();
                if (activeObject != null) {
                    oImg.set("angle", activeObject.angle);
                }
            }

            oImg.lockUniScaling = true;
            canvas.add(oImg);
            canvas.renderAll();
            canvas.setActiveObject(oImg);
            $(document).trigger("ps.canvas.stickermenu.showContextMenu", [oImg]);
            $(document).trigger("ps.canvas.undoredo.addToHistory");
        });
    }

    /**
     *
     */
    function isSomeObjectSelected() {
        return canvas.getActiveObject() == null ? false : true;
    }

    /**
     *
     */
    function scaleProportionally(sticker) {
        var w = sticker.image_width;
        var h = sticker.image_height;
        var fitToModel = sticker.properties.fit_to_model == 1;
        var wScale, hScale;

        // If we want for newly selected sticker to have the same zoom level as a target sticker has.
        if (fitToModel) {
            var aObj = canvas.getActiveObject() || canvas.getActiveGroup();
            if (aObj != null) {
                if (aObj.get('psOrigWidth') != null) {
                    // if there is a group of objects or only one object
                    wScale = aObj.get('psOrigWidth') / aObj.getWidth();
                } else {
                    // if there is a selection of some objects
                    wScale = 1;
                }

                if (aObj.get('psOrigHeight') != null) {
                    hScale = aObj.get('psOrigHeight') / aObj.getHeight();
                } else {
                    hScale = 1;
                }

                if (aObj._objects != null) {
                    // if it's a group, get scaling of one of the object in the group, preferable a model.
                    var baseObj = aObj.getObjects()[0];
                    aObj.forEachObject(function(obj) {
                        if (obj.get('psType') == 'model') {
                            baseObj = obj;
                        }
                    });
                    wScale *= baseObj.get('psOrigWidth') / baseObj.getWidth();
                    hScale *= baseObj.get('psOrigHeight') / baseObj.getHeight();
                }
            }
        }

        if (!(_.isNumber(wScale) && _.isNumber(hScale))) {
            wScale = PS_BASE_WIDTH / canvas.getWidth();
            hScale = PS_BASE_HEIGHT / canvas.getHeight();
        }

        w /= wScale;
        h /= hScale;

        return {
            width: Math.round(w),
            height: Math.round(h)
        };
    }

    /**
     *
     */
    function moveForward() {
        var obj = canvas.getActiveObject();
        var grp = canvas.getActiveGroup();
        //canvas.deactivateAll();

        if (obj != null) {
            obj.bringForward(true);
        }
        if (grp != null) {
            grp.forEachObject(function(obj) {
                obj.bringForward(true);
            });
        }
        canvas.renderAll();
        $(document).trigger("ps.canvas.undoredo.addToHistory");
    }

    /**
     *
     */
    function moveBackward() {
        var obj = canvas.getActiveObject();
        var grp = canvas.getActiveGroup();
        //canvas.deactivateAll();

        if (obj != null) {
            obj.sendBackwards(true);
        }
        if (grp != null) {
            var objectsOrdered = [];
            grp.forEachObject(function(obj) {
                objectsOrdered[grp.getObjects().indexOf(obj)] = obj;
            });
            var objectsSorted = _.sortBy(objectsOrdered, function(obj, index, ctx) {
                return index;
            });
            _.each(objectsSorted, function(obj) {
                obj.sendBackwards(true);
            });
        }
        canvas.renderAll();
        $(document).trigger("ps.canvas.undoredo.addToHistory");
    }

    function hasMirrorableStickers() {
        var obj = canvas.getActiveObject();
        var grp = canvas.getActiveGroup();
        var has = false;

        if (obj != null) {
            var s = psUtils().getStickerById(obj.psItemId);
            if (s && s.mirrorable) {
                has = true;
            }

            // TOOD: go deeper for mirrorable obj._objects if needed
        }
        if (has == false && grp != null) {
            grp.forEachObject(function(obj) {
                var s = psUtils().getStickerById(obj.psItemId);
                if (s && s.mirrorable) {
                    has = true;
                }
                // TOOD: go deeper for mirrorable obj._objects if needed
            });
        }

        return has;
    }

    /**
     *
     */
    function flip() {
        var obj = canvas.getActiveObject();
        var grp = canvas.getActiveGroup();
        //canvas.deactivateAll();

        if (obj != null) {
            var s = psUtils().getStickerById(obj.psItemId);
            if (s && s.mirrorable) {
                obj.flipX = !obj.flipX;
            }
        }
        if (grp != null) {
            grp.forEachObject(function(obj) {
                var s = psUtils().getStickerById(obj.psItemId);
                if (s && s.mirrorable) {
                    obj.flipX = !obj.flipX;
                }
            });
        }
        canvas.renderAll();
        $(document).trigger("ps.canvas.undoredo.addToHistory");
    }

    /**
     *
     */
    function group() {
        var group = canvas.getActiveGroup();
        if (group != null) {
            var objects = group.getObjects();
            canvas.deactivateAll();

            var clones = [];
            _.each(objects, function(obj) {
                clones.push(fabric.util.object.clone(obj));
            });

            var newGroup = new fabric.Group(clones);
            newGroup.set("psOrigWidth", newGroup.getWidth());
            newGroup.set("psOrigHeight", newGroup.getHeight());
            canvas.add(newGroup);

            _.each(objects, function(obj) {
                canvas.remove(obj);
            });
            canvas.remove(group);
            $(document).trigger("ps.canvas.undoredo.addToHistory");
        }
    }

    /**
     *
     */
    function ungroup() {
        var group = canvas.getActiveObject();
        if (group != null && group._objects != null) {
            var objects = group.getObjects();
            canvas.deactivateAll();
            var new_scale = group.currentWidth / group.originalState.width;

            _.each(objects, function(obj) {
                var clone = fabric.util.object.clone(obj);
                clone.set({
                    top: group.top + obj.top,
                    left: group.left + obj.left,
                    width: obj.getWidth(),
                    height: obj.getHeight(),
                    scaleX: new_scale,
                    scaleY: new_scale,
                    hasControls: true
                });
                canvas.add(clone);
            });

            _.each(objects, function(obj) {
                group.remove(obj);
            });

            canvas.remove(group);
            $(document).trigger("ps.canvas.undoredo.addToHistory");
        }
    }

    /**
     *
     */
    function remove() {
        var obj = canvas.getActiveObject();
        var grp = canvas.getActiveGroup();
        canvas.deactivateAll();

        if (obj != null) {
            canvas.remove(obj);
            psUtils().stickerRemovedFromCanvas(obj.psItemId);
        }
        if (grp != null) {
            grp.forEachObject(function(obj) {
                canvas.remove(obj);
            });
            canvas.remove(grp);
        }
        canvas.renderAll();
        $(document).trigger("ps.canvas.undoredo.addToHistory");
    }

    function loadScene(json, callback) {
        var ret = new $.Deferred();
        ret.done(function(result) {
            canvas.clear();
            if (result.backgroundImage == null) {
                canvas.backgroundImage = false;
            }
            canvas.loadFromJSON(result, function() {
                var ao = canvas.getObjects();
                if (ao) {
                    if (ao.length > 0) {
                        for (var i = 0; i < ao.length; i++) {
                            ao[i].lockUniScaling = true;
                        }
                    }
                }
                //              canvas.renderAll.bind(canvas);
                canvas.renderAll();
                if (callback) callback();
            });
        });
        $(document).trigger("ps.canvas.serializer.deserialize", [json, ret]);
    }

    /**
     *
     */
    function toJSON() {
        $("#jsondata-dialog").dialog((new psUtils()).getDialogConfig({
            autoOpen: true,
            width: 600,
            create: function() {
                $.proxy(psUtils().getDialogConfig().create, this)();
                $(this).find("button").click(function() {
                    var json = $('#jsondata-dialog textarea').val();
                    loadScene(json);
                    $("#jsondata-dialog").dialog("close");
                });
            }
        }));

        var ret = new $.Deferred();
        ret.done(function(result) {
            $("#jsondata-dialog textarea").val(result);
        });
        $(document).trigger("ps.canvas.serializer.serialize", [ret, true]);
    }
}