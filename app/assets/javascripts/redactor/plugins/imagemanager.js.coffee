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
            '<div id="images-loading">Loading...</div>' +
            '<button type="button" data-action="prev" class="btn btn-default"><i class="fa fa-chevron-left"></i> Previous page</button>' +
            '<button type="button" data-action="next" style="float: right;" class="btn btn-default">Next page ' +
            '<i class="fa fa-chevron-right"></i></button>' +
            '<form><label for="image_search_query">Find image:</label>' +
            '<input type="text" class="form-control" id="image_search_query" name="query"><br>' +
            '<button type="submit" class="btn btn-primary">Search</button></form>' +
            '<div style="margin-top: 20px" id="images-container"></div></div>')

      $('#redactor-modal-image-droparea').addClass('redactor-tab redactor-tab2').hide()
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

      loadImages = (e)->
        e.preventDefault()
        e.stopPropagation()
        query = $imageSearchTemplate.find('input').val()
        return if !query || query.length < 1
        $loading.show();
        $.ajax '../image_search',
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