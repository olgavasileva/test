#= require jquery
#= require jquery_ujs
#= require jquery.textfill

$ ->
  resizeText = ->
    $(".resize").textfill
      innerTag: ".cell"
      explicitHeight: 56
      changeLineHeight: true
      complete: ->
        $(".resize .cell").animate(opacity: 1.0)

  animateGraphs = ->
    $(".summary .graph").each ->
      percentage = Math.round $(this).data().percentage
      $percentage = $(this).find(".percentage")
      $(this).find(".bar-line").animate {
        width: percentage + "%"
        duration: "slow"
      }, {
        step: (now, fx)->
          if !isNaN(now)
            p = parseInt Math.round(now)
            $percentage.text(p + '%')
      }

  # Resize text after font is loaded
  setTimeout resizeText, 100

  # Animate the graph after a short delay
  setTimeout animateGraphs, 500
