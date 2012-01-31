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

      # # determine if we are using fallbacks
      def fallbacks?
        i18n_fallbacks = I18n.backend.class.included_modules.map(&:to_s).include?('I18n::Backend::Fallbacks')   # will be true if config.i18n.fallbacks => true in config
        i18n_fallbacks || translation_options[:fallbacks] == true
      end

      #-
      # # fetch the fallbacks from the i18n backend
      # def fallbacks
      #   fallbacks? ? I18n.fallbacks : nil
      # end

    end
  end
end
