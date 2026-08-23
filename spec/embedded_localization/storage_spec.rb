# encoding: utf-8
require 'spec_helper'

# One contract for every storage (yaml text column, json / jsonb column, hstore column):
# translations survive save + reload with Symbol keys, nil translations are kept,
# a freshly loaded record is not dirty, and assigning an unchanged value does not dirty it.

describe 'translation storage' do

  it 'rejects an unknown storage option' do
    lambda {
      Class.new(ActiveRecord::Base) do
        self.table_name = 'genres'
        translates :name, storage: :xml
      end
    }.should raise_error(ArgumentError, /storage/)
  end

  STORAGES.each do |storage|
    describe storage[:name] do
      let(:genre_class) { storage[:genre] }
      let(:movie_class) { storage[:movie] }

      before :each do
        I18n.locale = I18n.default_locale
        genre_class.delete_all
        movie_class.delete_all
      end

      it 'reports its storage' do
        genre_class.translation_storage.should eq storage[:storage]
        movie_class.translation_storage.should eq storage[:storage]
      end

      describe 'a model without a native column for the translated attribute' do
        let(:genre) do
          g = genre_class.new
          g.name = 'Science Fiction'
          g.description = 'an awesome genre'
          I18n.with_locale(:de) { g.name = 'Science-Fiction' }
          g.set_localized_attribute(:name, :ko, '공상 과학 소설')
          g.set_localized_attribute(:description, 'JP', 'すばらしいジャンル')   # String locale, any case
          g.save!
          genre_class.find(g.id)
        end

        it 'reloads every translation' do
          genre.name.should eq 'Science Fiction'
          genre.description.should eq 'an awesome genre'
          genre.name(:de).should eq 'Science-Fiction'
          genre.name(:ko).should eq '공상 과학 소설'
          genre.get_localized_attribute(:description, :jp).should eq 'すばらしいジャンル'
          genre.get_localized_attribute(:description, 'jp').should eq 'すばらしいジャンル'
        end

        it 'uses Symbol keys for locales and for attributes after reload' do
          genre.i18n.keys.should all(be_a(Symbol))
          genre.i18n.values.each { |translations| translations.keys.should all(be_a(Symbol)) }
        end

        it 'reports translated_locales, translation_coverage and translation_missing after reload' do
          genre.translated_locales.sort.should eq [:de, :en, :jp, :ko]
          genre.translation_coverage(:name).sort.should eq [:de, :en, :ko]
          genre.translation_coverage(:description).sort.should eq [:en, :jp]
          genre.translation_missing(:name).should eq [:jp]
          genre.translation_missing(:description).sort.should eq [:de, :ko]
        end

        it 'keeps a translation that was set to nil' do
          genre.set_localized_attribute(:name, :ko, nil)
          genre.save!
          reloaded = genre_class.find(genre.id)
          reloaded.name(:ko).should be_nil
          reloaded.translation_coverage(:name).should include(:ko)
        end

        it 'is not changed right after loading from the database' do
          genre.changed?.should be_falsy
        end

        it 'does not mark the record changed when a translation is set to its current value' do
          genre.name = 'Science Fiction'
          I18n.with_locale(:de) { genre.name = 'Science-Fiction' }
          genre.set_localized_attribute(:name, :ko, '공상 과학 소설')
          genre.changed?.should be_falsy
        end

        it 'marks the record changed when a translation changes, and saves it' do
          I18n.with_locale(:de) { genre.name = 'Sci-Fi' }
          genre.i18n_changed?.should be_truthy
          genre.save!
          genre_class.find(genre.id).name(:de).should eq 'Sci-Fi'
        end

        it 'stores a translation for another locale even when it equals the I18n.default_locale value' do
          genre.set_localized_attribute(:name, :fr, 'Science Fiction')
          genre.save!
          genre_class.find(genre.id).name(:fr).should eq 'Science Fiction'
        end

        it 'returns nil for a locale without translations, and for an attribute not translated in a locale' do
          genre.name(:fr).should be_nil
          genre.get_localized_attribute(:name, :fr).should be_nil
          genre.get_localized_attribute(:name, :jp).should be_nil
          genre.description(:ko).should be_nil
        end

        it 'initializes both the current locale and I18n.default_locale for a record created in another locale' do
          g = I18n.with_locale(:de) { genre_class.new }
          g.translated_locales.sort.should eq [:de, :en]
        end
      end

      describe 'a model with a native column for the translated attribute' do
        let(:movie) do
          m = movie_class.new
          m.title = 'Blade Runner'
          I18n.with_locale(:de) { m.title = 'Der Blade Runner' }
          m.save!
          movie_class.find(m.id)
        end

        it 'writes the I18n.default_locale value into the native column, other locales only into i18n' do
          movie.read_attribute(:title).should eq 'Blade Runner'
          movie.title(:de).should eq 'Der Blade Runner'
          movie_class.where(title: 'Blade Runner').count.should eq 1
          movie_class.where(title: 'Der Blade Runner').count.should eq 0
        end

        it 'keeps the native column and the i18n hash in sync when the default locale value changes' do
          movie.title = 'Blade Runner 2049'
          movie.save!
          reloaded = movie_class.find(movie.id)
          reloaded.read_attribute(:title).should eq 'Blade Runner 2049'
          reloaded.title(:en).should eq 'Blade Runner 2049'
          reloaded.title(:de).should eq 'Der Blade Runner'
        end

        it 'stores a translation for another locale even when it equals the native column value' do
          movie.set_localized_attribute(:title, :fr, 'Blade Runner')
          movie.save!
          movie_class.find(movie.id).title(:fr).should eq 'Blade Runner'
        end
      end

      if storage[:sql]
        it 'can be queried in SQL by a translated value' do
          scifi = genre_class.new(name: 'Science Fiction')
          I18n.with_locale(:de) { scifi.name = 'Science-Fiction' }
          scifi.save!
          genre_class.new(name: 'Horror').save!

          genre_class.where(storage[:sql].call(:de, :name), 'Science-Fiction').pluck(:id).should eq [scifi.id]
          genre_class.where(storage[:sql].call(:en, :name), 'Horror').count.should eq 1
        end
      end
    end
  end
end
