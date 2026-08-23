# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require File.expand_path("lib/embedded_localization/version", __dir__)

Gem::Specification.new do |spec|
  spec.name        = "embedded_localization"
  spec.version     = EmbeddedLocalization::VERSION
  spec.authors     = ["Tilo Sloboda"]
  spec.email       = ["tilo.sloboda@gmail.com"]
  spec.homepage    = "https://github.com/tilo/embedded_localization"
  spec.summary     = %q{Rails I18n: library for embedded ActiveRecord model/data translation}
  spec.description = %q{Rails I18n: a very lightweight tool to allow you to transparently store multiple translations of attributes directly inside each DB record -- no extra database tables needed to store the localization data! All translations of a record live in one column: a YAML text column, a json/jsonb column, or a PostgreSQL hstore column.}
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 2.5.0"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "https://github.com/tilo/embedded_localization/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/tilo/embedded_localization/issues"

  # Files shipped in the gem: everything tracked by git except the specs and the CI / git configuration.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{\A(?:spec/|\.(?:git|github|rspec|circleci))})
    end
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "activerecord", ">= 6"
  spec.add_development_dependency "i18n"
  spec.add_development_dependency "sqlite3"
end
