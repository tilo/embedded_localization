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

      # determine if we are using fallbacks
      def fallbacks?
        Rails.application.config.i18n.fallbacks   # check if fallbacks are configured in the application.rb file
        # translation_options[:fallbacks]   # not using Gem specific options anymore
      end
    end
  end
end
