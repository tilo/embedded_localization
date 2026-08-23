# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in embedded_localization.gemspec
gemspec

gem 'rake'

group :test do
  gem 'rspec'
  gem 'simplecov'
  gem 'i18n'
  gem 'pg' if ENV['DB'] == 'postgresql'      # DB=postgresql bundle exec rake  (jsonb and hstore columns)

  if ENV['RAILS_VERSION']                     # RAILS_VERSION=7.2 bundle exec rake
    gem 'activerecord', "~> #{ENV['RAILS_VERSION']}.0"
    gem 'sqlite3', Gem::Version.new(ENV['RAILS_VERSION']) < Gem::Version.new('7.1') ? '~> 1.4' : '>= 1.4'   # the sqlite adapter of Rails < 7.1 requires sqlite3 ~> 1.4
  else
    gem 'activerecord'
    gem 'sqlite3'
  end
end
