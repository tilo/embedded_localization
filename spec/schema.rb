ActiveRecord::Schema.define do
  self.verbose = false

  create_table :genres, :force => true do |t|
    t.text :i18n

    t.string :other
    t.timestamps
  end

  create_table :movies, :force => true do |t|
    t.string :title
    t.text   :i18n

    t.string :other
    t.timestamps
  end

  # json column: SQLite, MySQL and PostgreSQL all have one
  create_table :json_genres, :force => true do |t|
    t.json :i18n

    t.string :other
    t.timestamps
  end

  create_table :json_movies, :force => true do |t|
    t.string :title
    t.json   :i18n

    t.string :other
    t.timestamps
  end

  # jsonb and hstore columns: PostgreSQL only (DB=postgresql)
  if ENV['DB'] == 'postgresql'
    enable_extension 'hstore'

    create_table :jsonb_genres, :force => true do |t|
      t.jsonb :i18n

      t.string :other
      t.timestamps
    end

    create_table :jsonb_movies, :force => true do |t|
      t.string :title
      t.jsonb  :i18n

      t.string :other
      t.timestamps
    end

    create_table :hstore_genres, :force => true do |t|
      t.hstore :i18n

      t.string :other
      t.timestamps
    end

    create_table :hstore_movies, :force => true do |t|
      t.string :title
      t.hstore :i18n

      t.string :other
      t.timestamps
    end
  end
end
