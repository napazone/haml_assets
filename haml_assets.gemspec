# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "haml_assets/version"

Gem::Specification.new do |s|
  s.name        = "haml_assets"
  s.version     = HamlAssets::VERSION
  s.authors     = ["Les Hill", "Wes Gibbs"]
  s.email       = ["les@infbio.com", "wes@infbio.com"]
  s.homepage    = ""
  s.summary     = %q{Use Haml with Rails helpers in the asset pipeline}
  s.description = %q{Use Haml with Rails helpers in the asset pipeline}

  s.rubyforge_project = "haml_assets"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "haml"
  s.add_runtime_dependency "tilt"
end
