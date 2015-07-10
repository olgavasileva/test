#= require ./base

$ ->
  voteEl = $('#vote-tooltip')
  voteEl.text adUnitConfig.vote.text
  voteEl.css 'animation-duration', "#{adUnitConfig.vote.duration}s"

  answersCountEl = $('.answers-count')
  answersCount = parseInt answersCountEl.text()

  asnwersCount = 0 if isNaN answersCount

  answersCountElText = "See what #{answersCount} people think"
  answersCountElText2 = adUnitConfig.shareSuggest.text || 'Share with your friends!'

  answersCountEl.html "<div class='first'>" + answersCountElText + "</div>" +
      "<div class='second'>" + answersCountElText2 + "</div>"

  answersCountColor = answersCountEl.css('background-color')

  answersCountEl.css('transition-duration', "#{adUnitConfig.shareSuggest.duration}s")

  answersCountEl.find('.first').css('color', answersCountColor).css('background-color', 'white')
  answersCountEl.find('.second').css('color', 'white').css('background-color', answersCountColor)

  toggleAnswersCountEl = ->
    if answersCountEl.hasClass('flipped')
      answersCountEl.removeClass('flipped')
    else
      answersCountEl.addClass('flipped')

  setInterval toggleAnswersCountEl, 3000