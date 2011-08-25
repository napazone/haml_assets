module HamlAssets
  class Engine < ::Rails::Engine
    initializer "sprockets.haml", after: "sprockets.environment" do |app|
      app.assets.register_engine('.haml', HamlSprocketsEngine)
    end
  end
end
