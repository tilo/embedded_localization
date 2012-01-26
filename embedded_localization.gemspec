# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "embedded_localization/version"

Gem::Specification.new do |s|
  s.name        = "embedded_localization"
  s.version     = EmbeddedLocalization::VERSION
  s.authors     = ["Tilo Sloboda"]
  s.email       = ["tilo.sloboda@gmail.com"]
  s.homepage    = "http://www.unixgods.org/~tilo/Ruby/embedded_localization"
  s.summary     = %q{Rails I18n: library for embedded ActiveRecord 3 model/data translation}
  s.description = %q{Rails I18n: embedded_localization allows you to store translations for ActiveRecord 3 attributes right inside each attribute -- no extra table needed.}

  s.rubyforge_project = "embedded_localization"

  # s.platform = Gem::Platform::RUBY

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
