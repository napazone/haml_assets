module HamlAssets
  module Config
    extend self

    def look_in_app_views
      @look_in_app_views
    end

    def look_in_app_views=(look)
      @look_in_app_views = look
    end

    def haml_options
      return @haml_options if @haml_options

      if defined?(Haml::Template)
        @haml_options = Haml::Template.options
      end

      @haml_options
    end

    def haml_options=(opts)
      @haml_options = opts
    end
  end
end
