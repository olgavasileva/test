class TwoCents::EmbeddableUnitThemes < Grape::API
  resource :embeddable_unit_themes do
    helpers do
      params :auth do
        requires :auth_token, type: String, desc: "Obtain this from the instance's API."
      end

      params :id do
        requires :id, type: Integer, desc: 'ID of theme.'
      end

      params :theme do
        requires :title, type: String
        requires :main_color, type: String
        requires :color1, type: String
        requires :color2, type: String
      end

      params :optional_theme do
        optional :title, type: String
        optional :main_color, type: String
        optional :color1, type: String
        optional :color2, type: String
      end

      def serialize_theme(theme)
        theme_hash = {}
        [:id, :title, :main_color, :color1, :color2].each do |attr|
          theme_hash[attr] = theme.send(attr)
        end
        theme_hash
      end

      def theme_params
        params.to_h.slice *%w[id title main_color color1 color2]
      end
    end

    desc 'Create theme'
    params do
      use :auth
      use :theme
    end
    post do
      validate_user!

      theme = current_user.embeddable_unit_themes.create! theme_params

      serialize_theme theme
    end

    desc 'Update theme'
    params do
      use :auth
      use :id
      use :optional_theme
    end
    put do
      validate_user!

      theme_id = theme_params['id']
      theme = current_user.embeddable_unit_themes.find theme_id

      if theme
        theme.update_attributes! theme_params
        fail! 400, theme.errors.full_messages unless theme.valid?
      else
        fail! 404, "Theme #{theme_id} not found"
      end

      serialize_theme theme
    end

    desc 'Delete theme'
    params do
      use :auth
      use :id
    end
    delete do
      validate_user!
      theme_id = theme_params['id']
      theme = current_user.embeddable_unit_themes.find(theme_id)

      if theme
        theme.destroy
      else
        fail! 404, "Theme #{theme_id} not found"
      end

      {}
    end
  end
end