module EmbeddedLocalization
  module ActiveRecord
    module InstanceMethods

      # Returns the translation of attr_name for the given locale; nil if there is none.
      # - will convert given locale to symbol, e.g. "en","En" to :en
      # - with fallbacks (see ClassMethods#fallbacks?), a nil translation is looked up in the fallback locales instead:
      #   the chain configured in I18n.fallbacks, then I18n.default_locale (see ClassMethods#fallback_locales)
      def get_localized_attribute(attr_name, locale)
        attr_name = attr_name.to_sym
        locale    = normalize_locale(locale)

        translation = translation_for(attr_name, locale)
        return translation unless translation.nil? && self.class.fallbacks?

        self.class.fallback_locales(locale).each do |fallback_locale|
          translation = translation_for(attr_name, fallback_locale)
          return translation unless translation.nil?
        end
        nil
      end

      # Sets the translation of attr_name for the given locale.
      # - will convert given locale to symbol, e.g. "en","En" to :en
      # - for I18n.default_locale, a DB column with the attribute's name (if the user defined one) is written too,
      #   so that the default locale values can be used in SQL queries
      # - does nothing when the value is unchanged, so the record stays clean and its timestamps are not touched
      def set_localized_attribute(attr_name, locale, new_translation)
        attr_name = attr_name.to_sym
        locale    = normalize_locale(locale)

        return if translation_unchanged?(attr_name, locale, new_translation)

        self.i18n_will_change!     # for ActiveModel Dirty tracking
        if native_column?(attr_name) && locale == I18n.default_locale
          write_attribute(attr_name, new_translation)
        end
        self.i18n ||= Hash.new
        self.i18n[locale] ||= Hash.new
        self.i18n[locale][attr_name] = new_translation
      end

      # Returns all locales used for translation of all documents of this class.
      # returns an Array of Symbols
      #
      def translated_locales
        self.i18n.keys
      end

      # Returns Array of Symbols for all attributes of this class,
      #   which have translations through acts_as_i18n.
      # returns an Array of Symbols
      #
      def translated_attributes
        self.class.translated_attributes
      end

      # Checks whether field with given name is translated field.
      # Param String or Symbol
      # Returns true or false
      #
      def translated?(name)
        self.class.translated?(name)
      end

      # Purpose: to see the translation coverage
      # Returns a Hash of all translated attributes, each with a Hash of the locales it has translations for
      #
      def translation_coverage( attribute = nil )
        attrs = {}
        self.i18n.each do |lang,hash|
          hash.keys.each do |attr|
            attrs[attr.to_sym] ||= []
            attrs[attr.to_sym] << lang
          end
        end
        if attribute.nil?
          return attrs
        elsif attrs[attribute.to_sym]
          attrs[attribute.to_sym]
        elsif translated?(attribute)
          []
        else   # if it's not a translated attribute, return nil
          nil
        end
      end

      # Purpose: to quickly see if attribute translations are missing
      # Returns a Hash of attributes, each with a Hash of the locales that are missing translations
      # If an attribute has complete translation coverage, it will not be listed
      # If the result is an empty Hash, then no attributes are missing translations
      #
      # Needs all the desired locales to be present in 'translated_locales'
      # e.g. each locale must be present in at least one of the translated attributes
      #
      def translation_missing( attribute = nil )
        missing = {}
        current_locales_used = translated_locales  # ... across all attributes

        translated_attributes.each do |attr|
          missing_locales = current_locales_used - translation_coverage(attr.to_sym)
          if missing_locales.size > 0
            missing[attr.to_sym] = missing_locales
          end
        end
        if attribute.nil?
          return missing
        else
          return missing[attribute.to_sym]
        end
      end

      private

      # initializes the `i18n` attribute with an empty Hash for I18n.locale and for I18n.default_locale
      def initialize_i18n_hashes
        self.i18n ||= Hash.new
        self.i18n[ I18n.locale ]         ||= Hash.new
        self.i18n[ I18n.default_locale ] ||= Hash.new
      end

      def normalize_locale(locale)
        locale.is_a?(String) ? locale.downcase.to_sym : locale   # ensure that locale is always a symbol
      end

      # the stored translation of attr_name in locale; nil when the locale or the attribute is not there
      def translation_for(attr_name, locale)
        translations = self.i18n[locale]
        translations[attr_name] if translations
      end

      # did the user define a DB column with the name of the translated attribute?
      def native_column?(attr_name)
        has_attribute?(attr_name)
      end

      # true when the record already holds exactly this translation -- and, for I18n.default_locale on a model
      # with a native column for the attribute, the column holds it too
      def translation_unchanged?(attr_name, locale, new_translation)
        return false unless self.i18n.is_a?(Hash) && self.i18n[locale]
        return false unless self.i18n[locale][attr_name] == new_translation
        return true  unless locale == I18n.default_locale && native_column?(attr_name)

        read_attribute(attr_name) == new_translation
      end

    end
  end
end
