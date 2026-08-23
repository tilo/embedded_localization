module EmbeddedLocalization
  module Storage
    # ActiveRecord attribute type for a PostgreSQL hstore `i18n` column.
    #
    # hstore is a flat String => String map, so each translation is stored under the key "<locale>.<attribute>",
    # e.g. "de.name" => "Science-Fiction". In Ruby the gem works with the nested Hash {de: {name: "Science-Fiction"}}.
    # Reading and writing the hstore text format is delegated to ActiveRecord's own hstore type.
    class Hstore < ::ActiveRecord::Type::Value
      include ::ActiveModel::Type::Helpers::Mutable

      SEPARATOR = '.'.freeze

      def type
        :hstore
      end

      def deserialize(value)
        nest(hstore.deserialize(value))
      end

      def serialize(value)
        hstore.serialize(flatten(value))
      end

      def changed_in_place?(raw_old_value, new_value)
        deserialize(raw_old_value) != new_value
      end

      private

      # ActiveRecord registers the hstore type when the PostgreSQL adapter is loaded, i.e. when the connection is
      # established; it is looked up on first use, so a model can be defined before the connection exists.
      def hstore
        @hstore ||= ::ActiveRecord::Type.lookup(:hstore, adapter: :postgresql)
      end

      # {de: {name: "x"}} => {"de.name" => "x"}
      def flatten(translations)
        return translations unless translations.is_a?(::Hash)

        translations.each_with_object({}) do |(locale, attributes), flat|
          next unless attributes.is_a?(::Hash)

          attributes.each { |attr_name, value| flat["#{locale}#{SEPARATOR}#{attr_name}"] = value }
        end
      end

      # {"de.name" => "x"} => {de: {name: "x"}} ; keys without a separator are ignored
      def nest(flat)
        return flat unless flat.is_a?(::Hash)

        flat.each_with_object({}) do |(key, value), translations|
          locale, attr_name = key.split(SEPARATOR, 2)
          next unless attr_name

          (translations[locale.to_sym] ||= {})[attr_name.to_sym] = value
        end
      end
    end
  end
end
