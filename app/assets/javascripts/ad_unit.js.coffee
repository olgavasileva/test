#= require jquery
#= require jquery_ujs

$ ->
  $(document).on "click", ".submitable", (event)->
    form = $(this).closest("form")
    if form.length == 1
      event.preventDefault()
      $(this).closest("form").submit()
