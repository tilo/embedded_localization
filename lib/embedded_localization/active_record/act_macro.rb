module EmbeddedLocalization
  module ActiveRecord
    module ActMacro
      STORAGES = [:yaml, :json, :jsonb, :hstore].freeze

      # translates :name, :description                    # `i18n` is a text column, stored as YAML (default)
      # translates :name, :description, storage: :json     # `i18n` is a json or jsonb column
      # translates :name, :description, storage: :hstore   # `i18n` is a PostgreSQL hstore column
      # translates :name, :description, fallbacks: true    # a locale without translations reads the I18n.default_locale value
      #
      # for details about I18n fallbacks, check the source:
      # i18n-0.9.0/lib/i18n/backend/fallbacks.rb
      # i18n-0.9.0/lib/i18n/locale/fallbacks.rb
      def translates(*attr_names)
        return if translates?  # cludge to make sure we don't set this up twice..

        options = attr_names.extract_options!
        storage = (options[:storage] || :yaml).to_sym
        unless STORAGES.include?(storage)
          raise ArgumentError, "unknown storage: #{storage.inspect} -- use one of #{STORAGES.inspect}"
        end

        class_attribute :translated_attribute_names, :translation_options
        self.translated_attribute_names = attr_names.map(&:to_sym).sort.uniq
        self.translation_options        = options

        include InstanceMethods
        extend  ClassMethods

        # the `i18n` column holds all translations of the record as {locale => {attribute => value}}
        # we should also protect it from direct assignment by the user
        case storage
        when :yaml
          serialize :i18n, coder: YAML, type: Hash
        when :json, :jsonb
          attribute :i18n, EmbeddedLocalization::Storage::Json.new
        when :hstore
          attribute :i18n, EmbeddedLocalization::Storage::Hstore.new
        end

        after_initialize :initialize_i18n_hashes

        # dynamically define the accessors for the translated attributes:
        translated_attribute_names.each do |attr_name|
          define_method(attr_name) do |locale = I18n.locale|
            get_localized_attribute(attr_name, locale)
          end

          define_method("#{attr_name}=") do |new_translation|
            set_localized_attribute(attr_name, I18n.locale, new_translation)
          end
        end
      end

      def translates?
        included_modules.include?(InstanceMethods)
      end
    end
  end
end
