# encoding: utf-8
require 'spec_helper'

# Converting an existing YAML `i18n` text column to a json / jsonb / hstore column with the migration shown in the
# README ("Data Migration"): rename the old column, add the new one, copy every record's translations through a model
# that reads the old column with `serialize` and writes the new one with `translates ... storage:`, drop the old column.

describe 'converting the i18n column from YAML text to another storage' do
  STORAGES.reject { |s| s[:storage] == :yaml }.each do |storage|
    describe "to a #{storage[:name]}" do
      let(:connection) { ActiveRecord::Base.connection }

      before :each do
        I18n.locale = I18n.default_locale
        connection.create_table(:converted_genres, force: true) { |t| t.text :i18n }

        stub_const('YamlGenre', Class.new(ActiveRecord::Base) do
          self.table_name = 'converted_genres'
          translates :name, :description
        end)
        scifi = YamlGenre.new(name: 'Science Fiction')
        I18n.with_locale(:de) { scifi.name = 'Science-Fiction' }
        scifi.set_localized_attribute(:description, :jp, 'すばらしいジャンル')
        scifi.save!
        YamlGenre.new(name: 'Horror').save!
      end

      after :each do
        connection.drop_table(:converted_genres)
      end

      it 'keeps every translation and makes them queryable in SQL' do
        # the migration:
        connection.rename_column :converted_genres, :i18n, :i18n_yaml
        connection.add_column    :converted_genres, :i18n, storage[:storage]

        stub_const('MigrationGenre', Class.new(ActiveRecord::Base) do
          self.table_name = 'converted_genres'
          serialize :i18n_yaml, coder: YAML, type: Hash                      # the old column, read the way the gem wrote it
          translates :name, :description, storage: storage[:storage]         # the new column
        end)
        MigrationGenre.find_each do |genre|
          genre.update_column(:i18n, genre.i18n_yaml)
        end

        connection.remove_column :converted_genres, :i18n_yaml

        # the application afterwards:
        stub_const('ConvertedGenre', Class.new(ActiveRecord::Base) do
          self.table_name = 'converted_genres'
          translates :name, :description, storage: storage[:storage]
        end)
        ConvertedGenre.count.should eq 2

        scifi = ConvertedGenre.where(storage[:sql].call(:de, :name), 'Science-Fiction').first
        scifi.should_not be_nil
        scifi.name.should eq 'Science Fiction'
        scifi.name(:de).should eq 'Science-Fiction'
        scifi.description(:jp).should eq 'すばらしいジャンル'
        scifi.translated_locales.sort.should eq [:de, :en, :jp]

        ConvertedGenre.where(storage[:sql].call(:en, :name), 'Horror').count.should eq 1
      end
    end
  end
end
