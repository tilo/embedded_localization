# encoding: utf-8
require 'spec_helper'
require 'i18n/backend/fallbacks'   # defines I18n.fallbacks

# `translates ..., fallbacks: true` : a nil translation is looked up in the fallback locales instead --
# the chain configured in I18n.fallbacks, then I18n.default_locale.

describe 'fallbacks' do
  let(:genre) do
    g = FallbackGenre.new
    g.name = 'Science Fiction'
    I18n.with_locale(:de) { g.description = 'ein grossartiges Genre' }
    g
  end

  it 'reports fallbacks? from the translates option' do
    FallbackGenre.fallbacks?.should be_truthy
    Genre.fallbacks?.should be_falsy
  end

  describe 'to I18n.default_locale' do
    it 'falls back via the getter for a locale without any translations' do
      genre.name(:fr).should eq 'Science Fiction'
    end

    it 'falls back via get_localized_attribute for a locale without any translations' do
      genre.get_localized_attribute(:name, :fr).should eq 'Science Fiction'
      genre.get_localized_attribute(:name, 'FR').should eq 'Science Fiction'
    end

    it 'falls back when the locale has translations, but none for that attribute' do
      genre.name(:de).should eq 'Science Fiction'
      genre.get_localized_attribute(:name, :de).should eq 'Science Fiction'
    end

    it 'falls back for the current I18n.locale of a record loaded from the database' do
      genre.save!
      I18n.with_locale(:de) do
        reloaded = FallbackGenre.find(genre.id)
        reloaded.name.should eq 'Science Fiction'
        reloaded.description.should eq 'ein grossartiges Genre'
      end
    end

    it 'falls back when an existing translation was set to nil' do
      genre.set_localized_attribute(:name, :de, 'Science-Fiction')
      genre.set_localized_attribute(:name, :de, nil)
      genre.i18n[:de].should have_key(:name)               # the nil value is kept ...
      genre.name(:de).should eq 'Science Fiction'          # ... and the getter falls back
    end

    it 'returns nil when the default locale has no translation for the attribute either' do
      genre.description(:fr).should be_nil
    end

    it 'still returns the translation of the requested locale when there is one' do
      genre.description(:de).should eq 'ein grossartiges Genre'
    end

    it 'does not fall back for a model without the fallbacks option' do
      plain = Genre.new
      plain.name = 'Science Fiction'
      plain.name(:fr).should be_nil
      plain.get_localized_attribute(:name, :fr).should be_nil
    end
  end

  describe 'with a fallback chain configured in I18n.fallbacks' do
    before :each do
      @i18n_fallbacks = I18n.fallbacks
      I18n.fallbacks = I18n::Locale::Fallbacks.new(:"de-AT" => :de, :fr => :de)
    end

    after :each do
      I18n.fallbacks = @i18n_fallbacks
    end

    let(:genre) do
      g = FallbackGenre.new
      g.name = 'Science Fiction'
      g.description = 'an awesome genre'
      I18n.with_locale(:de) { g.name = 'Science-Fiction' }
      g
    end

    it 'lists the fallback locales: the configured chain, then I18n.default_locale, without the locale itself' do
      FallbackGenre.fallback_locales(:"de-AT").should eq [:de, :en]
      FallbackGenre.fallback_locales(:fr).should eq [:de, :en]
      FallbackGenre.fallback_locales(:ko).should eq [:en]
      FallbackGenre.fallback_locales(:en).should eq []
    end

    it 'uses the configured chain before I18n.default_locale' do
      genre.name(:"de-AT").should eq 'Science-Fiction'
      genre.name(:fr).should eq 'Science-Fiction'
      genre.get_localized_attribute(:name, 'de-AT').should eq 'Science-Fiction'
    end

    it 'continues to I18n.default_locale when no locale of the chain has the translation' do
      genre.description(:"de-AT").should eq 'an awesome genre'
    end

    it 'falls back to I18n.default_locale for a locale without a configured chain' do
      genre.name(:ko).should eq 'Science Fiction'
    end

    it 'prefers the translation of the requested locale over the chain' do
      I18n.with_locale(:"de-AT") { genre.name = 'Science-Fiction (AT)' }
      genre.name(:"de-AT").should eq 'Science-Fiction (AT)'
    end
  end
end
