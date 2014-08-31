class TwoCents::Studios < Grape::API
  helpers do
    def get_studio
      @studio = Studio.find(params[:studio_id]) rescue (fail! 400, "Studio with ID #{params[:studio_id]} not found")
    end

    def get_sticker_pack
      @sticker_pack = StickerPack.find(params[:sticker_pack_id]) rescue (fail! 400, "Sticker pack with ID #{params[:sticker_pack_id]} not found")
    end
  end

  resource :studios do
    desc "Get a studio", {
        notes: <<-END
        Returns data about the specified studio.

                  #### Example response
                  {
                    response: "ok"
                    studio: { display_name: "Breakfast",
                              welcome_message: "Welcome to the Breakfast studio",
                              scene_id: 1,
                              icon_url: "https://crashmob-development.s3.amazonaws.com/crashmob/studio/icon/10/breakfast.jpg",
                              updated_at: "2014-04-16T14:03:36.000Z"
                            }
                  }
        END
    }
    post '/:studio_id', http_codes: [
      [200, "4400 - Studio not found"]
    ] do
      get_studio
      {:response => 'ok', :studio => @studio.api_response}
    end

    desc "Get all of a studio's sticker packs", {
        notes: <<-END
        Returns data about the sticker packs in the specified studio.

                  #### Example response
                  {
                    response: "ok"
                    sticker_packs: [
                      {
                        id: 26,
                        display_name: "Cereal",
                        header_icon_url: "https://crashmob-development.s3.amazonaws.com/crashmob/sticker_pack/header_icon/26/cereal.jpeg",
                        updated_at: "2014-04-17T15:48:40.000Z",
                        sort_order: 0
                      },
                      {
                        id: 27,
                        display_name: "Fruit",
                        header_icon_url: "https://crashmob-development.s3.amazonaws.com/crashmob/sticker_pack/header_icon/27/fruit.jpg",
                        updated_at: "2014-04-17T15:47:47.000Z",
                        sort_order: 1
                      }
                    ]
                  }
        END
    }
    post '/:studio_id/sticker_packs', http_codes: [
        [200, "4400 - Studio not found"]
    ] do
      get_studio
      sticker_packs = []
      @studio.sticker_packs.each_with_index do |sp, idx|
        sticker_packs << sp.api_response({'sort_order' => idx})
      end
      {:response => "ok", :sticker_packs => sticker_packs}
    end

    desc "Get a particular sticker pack", {
        notes: <<-END
        Returns detailed data about the specified sticker pack.

                  #### Example response
                  {
                    response: "ok"
                    sticker_pack: {
                      id: 26,
                      display_name: "Cereal",
                      header_icon_url: "https://crashmob-development.s3.amazonaws.com/crashmob/sticker_pack/header_icon/26/cereal.jpeg",
                      updated_at: "2014-04-17T15:48:40.000Z"
                    }
                  }
        END
    }
    post '/:studio_id/sticker_packs/:sticker_pack_id', http_codes: [
        [200, "4400 - Studio not found"],
        [200, "4401 - Sticker Pack not found"]
    ] do
        get_studio
        get_sticker_pack
        {:response => "ok", :sticker_pack => @sticker_pack.api_response}
    end

    desc "Get all the stickers in a sticker pack", {
        notes: <<-END
        Returns the list of stickers in the specified sticker pack.

                  #### Example response
                  {
                    response: "ok"
                    backgrounds: [
                      {
                        id: 65,
                        display_name: "Tabletop 1",
                        mirrorable: false,
                        type: "Background",
                        sort_order: 11,
                        tags: [ ],
                        image_thumb_url: "https://crashmob-development.s3.amazonaws.com/uploads/sticker/image/65/thumb_tabletop1.jpeg",
                        image_url: "https://crashmob-development.s3.amazonaws.com/uploads/sticker/image/65/tabletop1.jpeg",
                        image_width: 275,
                        image_height: 183,
                        properties: { }
                      },
                      {
                        id: 66,
                        display_name: "Tabletop 2",
                        mirrorable: false,
                        type: "Background",
                        sort_order: 12,
                        tags: [ ],
                        image_thumb_url: "https://crashmob-development.s3.amazonaws.com/uploads/sticker/image/66/thumb_tabletop2.jpeg",
                        image_url: "https://crashmob-development.s3.amazonaws.com/uploads/sticker/image/66/tabletop2.jpeg",
                        image_width: 311,
                        image_height: 162,
                        properties: { }
                      }
                    ],
                    stickers: [
                      {
                        id: 55,
                        display_name: "Cheerios",
                        mirrorable: false,
                        type: "Sticker",
                        sort_order: 1,
                        tags: [ ],
                        image_thumb_url: "https://crashmob-development.s3.amazonaws.com/uploads/sticker/image/55/thumb_cheerios.jpeg",
                        image_url: "https://crashmob-development.s3.amazonaws.com/uploads/sticker/image/55/cheerios.jpeg",
                        image_width: 120,
                        image_height: 135,
                        properties: {
                          brand: "General Mills",
                          sugar: "little"
                        }
                      },
                      {
                        id: 56,
                        display_name: "Frosted Flakes",
                        mirrorable: false,
                        type: "Sticker",
                        sort_order: 2,
                        tags: [ ],
                        image_thumb_url: "https://crashmob-development.s3.amazonaws.com/uploads/sticker/image/56/thumb_ff.jpeg",
                        image_url: "https://crashmob-development.s3.amazonaws.com/uploads/sticker/image/56/ff.jpeg",
                        image_width: 95,
                        image_height: 126,
                        properties: {
                          brand: "Kellog's",
                          sugar: "lots"
                        }
                      }
                    ]
                  }
        END
    }
    post '/:studio_id/sticker_packs/:sticker_pack_id/stickers', http_codes: [
        [200, "4400 - Studio not found"],
        [200, "4401 - Sticker Pack not found"]
    ] do
      get_studio
      get_sticker_pack
      backgrounds = []
      @sticker_pack.backgrounds.each do |bg|
        backgrounds << bg.api_response
      end
      stickers = []
      @sticker_pack.available_stickers.each do |s|
        stickers << s.api_response
      end
      { :response => "ok", :backgrounds => backgrounds, :stickers => stickers }
    end

    desc "Get a particular sticker", {
        notes: <<-END
        Returns data about the specified sticker.

                  #### Example response
                  {
                    response: "ok"
                    sticker: {
                      id: 55,
                      display_name: "Cheerios",
                      mirrorable: false,
                      type: "Sticker",
                      sort_order: 1,
                      tags: [ ],
                      image_thumb_url: "https://crashmob-development.s3.amazonaws.com/uploads/sticker/image/55/thumb_cheerios.jpeg",
                      image_url: "https://crashmob-development.s3.amazonaws.com/uploads/sticker/image/55/cheerios.jpeg",
                      image_width: 120,
                      image_height: 135,
                      properties: {
                        brand: "General Mills",
                        sugar: "little"
                      }
                    }
                  }
       END
    }
    post '/:studio_id/stickers/:sticker_id', http_codes: [
        [200, "4400 - Studio not found"],
        [200, "4402 - Sticker not found"]
    ] do
      get_studio
      sticker = Sticker.find(params[:sticker_id]).api_response rescue (fail! 400, "Sticker with ID #{params[:sticker_id]} not found")
      {:response => "ok", :sticker => sticker}
    end

    desc "Get thumbnail images for all stickers in a studio", {
        notes: <<-END
        Returns the list of thumbnail images for all stickers in the studio.

                  #### Example response
                  [
                    "https://crashmob-development.s3.amazonaws.com/uploads/sticker/image/65/thumb_tabletop1.jpeg",
                    "https://crashmob-development.s3.amazonaws.com/uploads/sticker/image/66/thumb_tabletop2.jpeg",
                    "https://crashmob-development.s3.amazonaws.com/uploads/sticker/image/55/thumb_cheerios.jpeg"
                  ]
        END
    }

    post '/:studio_id/sticker_thumbnails', http_codes: [
        [200, "4400 - Studio not found"],
    ] do
      get_studio
      thumbnails = []
      @studio.sticker_packs.each do |sp|
        sp.backgrounds.each do |bg|
          thumbnails << bg.image.thumb.url
        end
        sp.available_stickers.each do |s|
          thumbnails << s.image.thumb.url
        end
      end
      thumbnails
    end

  end
end
