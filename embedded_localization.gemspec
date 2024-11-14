# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "embedded_localization/version"

Gem::Specification.new do |spec|
  spec.name        = "embedded_localization"
  spec.version     = EmbeddedLocalization::VERSION
  spec.authors     = ["Tilo Sloboda"]
  spec.email       = ["tilo.sloboda@gmail.com"]
  spec.homepage    = "https://github.com/tilo/embedded_localization"
  spec.summary     = %q{Rails I18n: library for embedded ActiveRecord model/data translation}
  spec.description = %q{Rails I18n: Embedded_Localization for ActiveRecord is very lightweight, and allows you to transparently store translations of attributes right inside each record -- no extra database tables needed to store the localization data!}

  # spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = ">= 2.5.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/tilo/embedded_localization/blob/master/CHANGELOG.md"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.licenses = ['MIT']
  # specify any dependencies here; for example:
  spec.add_development_dependency "codecov"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "activerecord", ">= 6"
  spec.add_development_dependency "i18n"
  spec.add_development_dependency "sqlite3"
  # spec.add_runtime_dependency "rest-client"
end
