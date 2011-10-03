require "haml_assets/version"

if defined? Rails
  if Rails.version.to_f >= 3.1
    require "haml_assets/engine"
  end
end

module HamlAssets
  autoload :HamlSprocketsEngine, "haml_assets/haml_sprockets_engine"
end
