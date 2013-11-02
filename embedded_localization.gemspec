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
  s.description = %q{Rails I18n: Embedded_Localization for ActiveRecord 3 is very lightweight, and allows you to transparently store translations of attributes right inside each record -- no extra database tables needed to store the localization data!}

#  s.rubyforge_project = "embedded_localization"
  s.rubyforge_project = "[none]"

  # s.platform = Gem::Platform::RUBY

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.licenses = ['MIT','GPL-2']
  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
