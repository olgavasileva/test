if !window.tcHandlers
  window.tcHandlers={}

window.tcHandlers.usedImages=[]


$ ->
  change_image_by = (delta, scope) ->
    if(!window.tcHAndlers)
      window.tcHAndlers={}

    if(!window.tcHAndlers.usedImages)
      window.tcHAndlers.usedImages=[]

    url=''
    $image = $(scope).find(".bgimage img")
    $id_field = $(scope).find(".id input")
    canned=$(scope).find(".canned");
    ids = canned.data("ids")
    urls = canned.data("urls")
    max = urls.length
    local_url=$image.attr("src")
    i = $.inArray $image.attr("src"), urls

    if i<0
      urls.unshift local_url
      i=0
      canned.data("urls",urls)
      ids.unshift($id_field.val());

    if i >= 0
      i = i + delta

      if i < 0
        i += max
      else
        i = i % max

      url=urls[i]
      if(window.tcHAndlers.usedImages.indexOf(url)>=0)
        change_image_by (delta+delta/Math.abs(delta)),scope
      else
        current_url=$image.attr "src"
        current_ul_id=window.tcHAndlers.usedImages.indexOf current_url

        if(current_ul_id>=0)
          window.tcHAndlers.usedImages.splice current_ul_id, 1
        $image.attr "src", url
        $id_field.val ids[i]
        window.tcHAndlers.usedImages.push url

  $(document).on "click", ".image_control a.next_image", (e)->
    e.preventDefault()
    change_image_by 1, $(this).closest(".imagechooser")

  $(document).on "click", ".image_control a.prev_image", (e)->
    e.preventDefault()
    change_image_by -1, $(this).closest(".imagechooser")

  $(document).on 'click','.question-image-uploader',(e)->
    $(this).find('[type="file"]')[0].click()

  $(document).on 'change','.question-image-uploader input[type="file"]',(e)->
    type=$(this).data('image-type')
    data = new FormData()
    data.append((type+"_image[image]"), this.files[0])

    $.ajax({
      url: "/"+type+"_images",
      data: data,
      cache: false,
      contentType: false,
      processData: false,
      type: 'POST',
      success: (data)->
        scope=$(this).closest(".imagechooser")
        $image = $(scope).find(".bgimage img")
        $id_field = $(scope).find(".id input")
        canned=$(scope).find(".canned");
        ids = canned.data("ids")
        urls = canned.data("urls")
        ids.unshift(data.id)
        urls.unshift(data.url)
        canned.data('ids',ids)
        canned.data('urls',urls)
        $image.attrs('src',data.url)
        $id_field.val(data.id)

    })

  $(document).on 'click','.tc-dropdown .dropdown-menu-item', ()->
    root=$(this).parent().parent()
    text=$(this).html()
    value=$(this).attr('data-value')||text
    root.find('.value-holder').val(value)
    root.find('.value-label').html(text)

  $(document).on 'keydown','.remove-default-text, .rem ove-default-text textarea', ()->
    $(this).val('');
    node=$(this).parent();
    $(this).removeClass('remove-default-text');
    $(node).removeClass('remove-default-text');


  return null
