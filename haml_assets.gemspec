# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "haml_assets/version"

Gem::Specification.new do |s|
  s.name        = "haml_assets"
  s.version     = HamlAssets::VERSION
  s.authors     = ["Les Hill", "Wes Gibbs"]
  s.email       = ["leshill@gmail.com", "wes@infbio.com"]
  s.homepage    = "https://github.com/carezone/haml_assets"
  s.summary     = %q{Use Haml with Rails helpers in the asset pipeline}
  s.description = %q{Use Haml with Rails helpers in the asset pipeline}

  s.rubyforge_project = "haml_assets"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "haml"
  s.add_runtime_dependency "tilt", "< 3", ">= 1.4"

  s.add_development_dependency 'rails', '~> 4.0'
  s.add_development_dependency 'rspec', '~> 2.13.0'
  s.add_development_dependency 'rspec-rails', '~> 2.13.0'
  s.add_development_dependency 'ejs'
  s.add_development_dependency 'test-unit', '~> 3.1.5'
end
