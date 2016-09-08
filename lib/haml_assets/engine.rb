module HamlAssets
  class Engine < ::Rails::Engine
    initializer "haml_assets.assets.register", :group => :all do |app|
      app.config.assets.configure do |sprockets_env|
        if sprockets_env.respond_to?(:register_transformer)
          sprockets_env.register_mime_type 'application/vnd.carezone.haml+text', extensions: ['.haml']
          sprockets_env.register_transformer 'application/vnd.carezone.haml+text', 'application/javascript', HamlSprocketsEngine
        end

        if sprockets_env.respond_to?(:register_engine)
          args = ['.haml', HamlSprocketsEngine]
          args << { silence_deprecation: true } if Sprockets::VERSION.start_with?("3")
          sprockets_env.register_engine(*args)
        end
      end
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
