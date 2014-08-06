$ ->
  $(document).on "click", "a.next_image", (e)->
    e.preventDefault()

    i = parseInt $("form .index input").val()
    max = $(".canned").length

    i = (i + 1) % max
    $("form .index input").val(i)
    $(".bgimage img").attr "src", $($(".canned")[i]).html()


  $(document).on "click", "a.prev_image", (e)->
    e.preventDefault()

    i = parseInt $("form .index input").val()
    max = $(".canned").length

    i = if i == 0 then max - 1 else i - 1

    $("form .index input").val(i)
    $(".bgimage img").attr "src", $($(".canned")[i]).html()
