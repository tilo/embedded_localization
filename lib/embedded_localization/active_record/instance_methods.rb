module EmbeddedLocalization
  module ActiveRecord
    module InstanceMethods

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
#        self.class.instance_variable_get(translated_attribute_names).include?(name.to_sym)
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
        else
          return attrs[attribute.to_sym]
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
      # initialized the serialized 'i18n' attribute with Hash of Hashes,
      #   containing all pre-defined translated attributes with nil value
      def initialize_i18n_hashes
        self.i18n ||= HashWithIndifferentAccess.new
        self.i18n[ I18n.locale ] ||= HashWithIndifferentAccess.new(Hash.zip(translated_attribute_names,[]))
        if I18n.locale != I18n.default_locale
          self.i18n[ I18n.default_locale ] ||= HashWithIndifferentAccess.new(Hash.zip(translated_attribute_names,[]))
        end
      end

    end
  end
end
