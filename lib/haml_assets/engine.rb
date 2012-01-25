module HamlAssets
  class Engine < ::Rails::Engine
    initializer "sprockets.haml", :after => "sprockets.environment", :group => :all do |app|
      next unless app.assets

      app.assets.register_engine('.haml', HamlSprocketsEngine)
    end
  end
end

module HamlAssets
  class Railtie < ::Rails::Railtie
    if ::Rails.version.to_f >= 3.1
      config.app_generators.javascript_template_engine :haml
    end
  end
end
