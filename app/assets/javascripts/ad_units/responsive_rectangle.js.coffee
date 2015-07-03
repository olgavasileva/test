#= require ./base

$ ->
  voteEl = $('#vote-tooltip')
  voteEl.text adUnitConfig.vote.text
  voteEl.css 'animation-duration', "#{adUnitConfig.vote.speed}s"

  answersCountEl = $('.answers-count')
  answersCount = parseInt answersCountEl.text()

  asnwersCount = 0 if isNaN answersCount

  answersCountElText = "See what #{answersCount} people think"
  answersCountElText2 = 'Share with your friends!'

  answersCountEl.html "<div class='first'>" + answersCountElText + "</div>" +
      "<div class='second'>" + answersCountElText2 + "</div>"

  answersCountColor = answersCountEl.css('background-color')

  toggleAnswersCountEl = ->
    if answersCountEl.hasClass('flipped')
      answersCountEl.removeClass('flipped')
    else
      answersCountEl.addClass('flipped')
    setTimeout(->
      if answersCountEl.css('background-color') == answersCountColor
        answersCountEl.css('color', answersCountColor)
        answersCountEl.css('background-color', 'white')
      else
        answersCountEl.css('color', 'white')
        answersCountEl.css('background-color', answersCountColor)
    , 500)
  setInterval toggleAnswersCountEl, 3000