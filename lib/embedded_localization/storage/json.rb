module EmbeddedLocalization
  module Storage
    # ActiveRecord attribute type for a json or jsonb `i18n` column.
    #
    # The column holds {"en" => {"name" => "..."}, "de" => {...}}; in Ruby the gem works with Symbol keys on both
    # levels, so this type converts the keys whenever a value comes from the database. Assignment goes through the
    # same conversion: ActiveRecord::Type::Json includes ActiveModel::Type::Helpers::Mutable, whose cast(value) is
    # deserialize(serialize(value)).
    class Json < ::ActiveRecord::Type::Json
      def deserialize(value)
        symbolize_keys(super)
      end

      private

      def symbolize_keys(translations)
        return translations unless translations.is_a?(::Hash)

        translations.each_with_object({}) do |(locale, attributes), result|
          result[locale.to_sym] = attributes.is_a?(::Hash) ? attributes.transform_keys(&:to_sym) : attributes
        end
      end
    end
  end
end
