require 'rubygems'
require 'active_record'
require 'i18n'
require 'bundler/setup'

Bundler.require(:default)

require 'embedded_localization'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

load File.dirname(__FILE__) + '/schema.rb'
require File.dirname(__FILE__) + '/models.rb'


I18n.enforce_available_locales = false
I18n.config.available_locales = [:ru,:jp,:ko,:fr,:en,:de]

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :should
  end
  config.mock_with :rspec do |mocks|
    mocks.syntax = :should
  end

  config.filter_run_including :focus => true
  config.run_all_when_everything_filtered = true
end
