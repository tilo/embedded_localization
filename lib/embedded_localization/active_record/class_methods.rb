module EmbeddedLocalization
  module ActiveRecord
    module ClassMethods

      # Returns Array of Symbols for all attributes of this class, 
      #   which have translations through acts_as_i18n.
      # returns an Array of Symbols
      def translated_attributes
        translated_attribute_names
      end

      # Checks whether field with given name is translated field.
      # Param String or Symbol
      # Returns true or false
      def translated?(name)
        translated_attribute_names.include?(name.to_sym)
      end

      # How the `i18n` column is stored: :yaml (text column, the default), :json, :jsonb or :hstore
      def translation_storage
        (translation_options[:storage] || :yaml).to_sym
      end

      # # determine if we are using fallbacks
      def fallbacks?
        i18n_fallbacks = I18n.backend.class.included_modules.map(&:to_s).include?('I18n::Backend::Fallbacks')   # will be true if config.i18n.fallbacks => true in config
        i18n_fallbacks || translation_options[:fallbacks] == true
      end

      # The locales to look at, in order, when `locale` has no translation for an attribute:
      # the chain configured in I18n.fallbacks (e.g. config.i18n.fallbacks = { 'de-AT' => 'de' } gives :de for :"de-AT";
      # I18n.fallbacks exists once i18n/backend/fallbacks is loaded, which Rails does for config.i18n.fallbacks),
      # followed by I18n.default_locale. `locale` itself is not part of the result.
      def fallback_locales(locale)
        chain = I18n.respond_to?(:fallbacks) ? I18n.fallbacks[locale] : []
        (chain + [I18n.default_locale]).uniq - [locale]
      end

      #-
      # # fetch the fallbacks from the i18n backend
      # def fallbacks
      #   fallbacks? ? I18n.fallbacks : nil
      # end

    end
  end
end
