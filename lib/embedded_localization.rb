require "embedded_localization/version"
require 'extensions/hash'

module EmbeddedLocalization
  autoload :ActiveRecord, 'embedded_localization/active_record'
end

# we're assuming for now only to be used with ActiveRecord 3, which is auto-required above
ActiveRecord::Base.extend(EmbeddedLocalization::ActiveRecord::ActMacro)

#-
# ------------------------------------------------------------------------------------------------------
# probably a good idea to keep our own implementation of fallbacks,
# because we only want to fallback to I18n.default_locale .. nothing more complicated for now.
# ------------------------------------------------------------------------------------------------------
#
# Fallbacks:  https://github.com/svenfuchs/i18n/wiki/Fallbacks
#
# The problem is that the I18n backends are meant for static strings in the views, helpers, etc.; not for model data.
# Switching on the current I18n backend's fallbacks will allow us to use that backend's mappings from one locale to the fallbacks, 
# but we still need to search for the translated module data in our serialized i18n attribute hash ourselves.

# to enable I18n fallbacks:
# require "i18n/backend/fallbacks" 
# I18n.backend.class.send(:include, I18n::Backend::Fallbacks)

# Thread.current[:i18n_config].backend
# ?? I18n.fallbacks.map('es' => 'en') ?? doesn't seem to work as expected..

# not as general:
# I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)

