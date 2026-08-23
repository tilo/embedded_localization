require 'logger'   # Rails 6.1 with concurrent-ruby >= 1.3.5: ActiveSupport::LoggerThreadSafeLevel needs ::Logger loaded first
require 'active_record'
require 'i18n'

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter "/pkg/"
end

require 'embedded_localization'

# DB=postgresql runs the suite against PostgreSQL, which is needed for the jsonb and hstore columns.
# The connection details come from the PG* environment variables (PGHOST, PGUSER, PGPASSWORD, PGDATABASE).
if ENV['DB'] == 'postgresql'
  ActiveRecord::Base.establish_connection adapter: 'postgresql', database: ENV.fetch('PGDATABASE', 'embedded_localization_test')
else
  ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
end

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
