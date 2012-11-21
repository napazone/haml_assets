module HamlAssets
  module Config
    extend self

    def look_in_app_views
      @look_in_app_views
    end

    def look_in_app_views=(look)
      @look_in_app_views = look
    end
  end
end
