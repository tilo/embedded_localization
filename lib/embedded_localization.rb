require "embedded_localization/version"
require 'extensions/hash'

module EmbeddedLocalization
  autoload :ActiveRecord, 'embedded_localization/active_record'

  class << self
    class_attribute :fallback

    def fallback?
      fallback == true
    end
  end
end

# we're assuming for now only to be used with ActiveRecord 3, which is auto-required above
ActiveRecord::Base.extend(EmbeddedLocalization::ActiveRecord::ActMacro)
