class Genre < ActiveRecord::Base
   translates :name, :description
end

class Movie < ActiveRecord::Base
   translates :title, :description
end

# same table as Genre, with fallbacks to I18n.default_locale enabled
class FallbackGenre < ActiveRecord::Base
  self.table_name = 'genres'
  translates :name, :description, fallbacks: true
end

class JsonGenre < ActiveRecord::Base
  translates :name, :description, storage: :json
end

class JsonMovie < ActiveRecord::Base
  translates :title, :description, storage: :json
end

if ENV['DB'] == 'postgresql'
  class JsonbGenre < ActiveRecord::Base
    translates :name, :description, storage: :jsonb
  end

  class JsonbMovie < ActiveRecord::Base
    translates :title, :description, storage: :jsonb
  end

  class HstoreGenre < ActiveRecord::Base
    translates :name, :description, storage: :hstore
  end

  class HstoreMovie < ActiveRecord::Base
    translates :title, :description, storage: :hstore
  end
end

# Every storage the current database supports.
# :sql builds the WHERE fragment (with one `?` placeholder) that finds a record by one translated value;
# it is nil for the YAML text column, which cannot be queried by value.
STORAGES = [
  { name: 'yaml text column', storage: :yaml, genre: Genre, movie: Movie, sql: nil },
]

if ENV['DB'] == 'postgresql'
  STORAGES << { name: 'json column',   storage: :json,   genre: JsonGenre,   movie: JsonMovie,   sql: ->(locale, attr) { "i18n -> '#{locale}' ->> '#{attr}' = ?" } }
  STORAGES << { name: 'jsonb column',  storage: :jsonb,  genre: JsonbGenre,  movie: JsonbMovie,  sql: ->(locale, attr) { "i18n -> '#{locale}' ->> '#{attr}' = ?" } }
  STORAGES << { name: 'hstore column', storage: :hstore, genre: HstoreGenre, movie: HstoreMovie, sql: ->(locale, attr) { "i18n -> '#{locale}.#{attr}' = ?" } }
else
  STORAGES << { name: 'json column',   storage: :json,   genre: JsonGenre,   movie: JsonMovie,   sql: ->(locale, attr) { "json_extract(i18n, '$.#{locale}.#{attr}') = ?" } }
end
