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
end
