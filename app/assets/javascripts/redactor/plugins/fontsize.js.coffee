(($) ->
  $.Redactor::fontsize = ->
    {
    init: ->
      fonts = [10, 11, 12, 14, 16, 18, 20, 24, 28, 30, 36, 48, 60, 72, 96]
      that = this
      dropdown = {}
      $.each fonts, (i, s) ->
        dropdown['s' + i] =
          title: s + 'px'
          func: ->
            that.fontsize.set s
            return
        return
      dropdown.remove =
        title: 'Remove Font Size'
        func: that.fontsize.reset
      button = @button.add('fontsize', 'Change Font Size')
      @button.addDropdown button, dropdown
      return
    set: (size) ->
      @inline.format 'span', 'style', 'font-size: ' + size + 'px;'
      return
    reset: ->
      @inline.removeStyleRule 'font-size'
      return

    }

  return) jQuery
