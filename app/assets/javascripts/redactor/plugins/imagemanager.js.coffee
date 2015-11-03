(($) ->
  $.Redactor::imagemanager = ->
    {
    init: ->
      @modal.addCallback 'image', @imagemanager.load
      return
    load: ->
      $modal = @modal.getModal()
      @modal.createTabber $modal
      @modal.addTab 1, 'Image Search', 'active'
      @modal.addTab 2, 'Upload'

      $imageSearchTemplate =
        $('<div id="redactor-image-manager-box" class="redactor-tab redactor-tab1">' +
            '<form><div class="input-group">' +
            '<input style="margin-top: -10px; height: 32px" type="text" placeholder="Cute cats, emojis, sushi..." ' +
            'class="form-control" id="image_search_query" name="query">' +
            '<span class="input-group-btn"><button type="submit" style="margin-top: -10px;" class="btn btn-primary">' +
            '<i class="fa fa-search"></i></button></span></form></div><br>' +
            '<div id="images-loading">Loading...</div>' +
            '<div style="margin-top: 20px" id="images-container"></div><br />' +
            '<a data-action="prev"><i class="fa fa-chevron-left"></i> Previous</a>' +
            '<a data-action="next" style="float: right;">Next <i class="fa fa-chevron-right"></i></a></div>')

      $('#redactor-modal-image-droparea').addClass('redactor-tab redactor-tab2').hide()

      $('#redactor-modal-header').text 'Choose an image:'

      $('[rel="tab2"]').click ->
        $newStandartUploadTemplate = $('<div>Drop file here<br />Or, if you prefer ... ' +
          ' <button type="button" id="browse-files" class="btn btn-default">upload a file</button>' +
            '</div>').append($('#redactor-droparea-placeholder input').hide());
        $newStandartUploadTemplate.find('button').click (e)->
          $newStandartUploadTemplate.find('input').click()
        $('#redactor-modal-image-droparea #redactor-droparea-placeholder').html $newStandartUploadTemplate

      $modal.append $imageSearchTemplate

      self = @
      currentPage = 1
      $container = $imageSearchTemplate.find('#images-container')
      $loading = $imageSearchTemplate.find('#images-loading').hide()

      setImages = (images) ->
        $container.html('')
        images.forEach (image)->
          $image = $('<img style="cursor: pointer" width="100" src="' + image.thumbnail +
              '" height="100" rel="' + image.media_url + '">')
          $image.click $.proxy(self.imagemanager.insert, self)
          $container.append $image
      self = @
      loadImages = (e)->
        e.preventDefault()
        e.stopPropagation()
        query = $imageSearchTemplate.find('input').val()
        return if !query || query.length < 1
        $loading.show();
        $.ajax self.opts.imageSearch,
          method: 'POST'
          data:
            query: query
            page: currentPage
          dataType: 'json'
          success: (response)->
            setImages(response)
            $loading.hide();
          failure: ->
            $loading.hide();

      $imageSearchTemplate.find('button').click (e)->
        currentPage = 1
        loadImages(e)
      $imageSearchTemplate.find('[data-action="prev"]').click (e)->
        currentPage = if currentPage == 1 then 1 else (currentPage - 1)
        loadImages(e)
      $imageSearchTemplate.find('[data-action="next"]').click (e)->
        currentPage += 1
        loadImages(e)

      return
    insert: (e) ->
      @image.insert '<img src="' + $(e.target).attr('rel') + '" alt="' + $(e.target).attr('title') + '" width="540">'
      return

    }

  return) jQuery