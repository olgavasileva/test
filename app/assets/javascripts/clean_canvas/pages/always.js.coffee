#= require social-share-button
$ ->
  verticalAutoCenter()
$(document).on "page:load", ->
  verticalAutoCenter()

verticalAutoCenter=()->
  $('.auto-center').css({top:'50%','margin-top':('-'+( $('.auto-center').outerHeight()/2)+'px'),position:'absolute'})

window.customAutoResize=()->
  $(this).height(0)
  $(this).height(this.scrollHeight)
  if $(this).hasClass('auto-center')
    repositionNode=$(this)
  else
    repositionNode=$(this).closest('.auto-center')
  if(repositionNode)
    repositionNode.css({top:'50%','margin-top':('-'+(repositionNode.outerHeight()/2)+'px'),position:'aboslute'})
