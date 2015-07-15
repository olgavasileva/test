#= require ./base
#= require ./responsive_rectangle/overlay_cta
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

  showCheckmark = ->
    window.clearCta()
    $el = $(@)
    isSelected = $el.find('.overlay').css('display') != 'none'
    isCheckboxHidden = $el.find('.is-selected').css('display') == 'none'
    if isSelected && isCheckboxHidden
      $el.find('.is-selected').css('display', 'block')
    else
      $el.find('.is-selected').css('display', 'none')

  $('.TextChoiceQuestion:not(.has-response) button[type="submit"]').click showCheckmark

  $('.ImageChoiceQuestion:not(.has-response) .image-choice').click showCheckmark
  $('.MultipleChoiceQuestion:not(.has-response) .image-choice').click showCheckmark

  $('.tooltip').tooltipster(
    theme: 'tooltipster-theme'
  )