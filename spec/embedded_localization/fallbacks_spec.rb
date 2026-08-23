# encoding: utf-8
require 'spec_helper'

# `translates ..., fallbacks: true` : reading a locale without translations returns the I18n.default_locale value

describe 'fallbacks to I18n.default_locale' do
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

  it 'falls back via the getter for a locale without any translations' do
    genre.name(:fr).should eq 'Science Fiction'
  end

  it 'falls back via get_localized_attribute for a locale without any translations' do
    genre.get_localized_attribute(:name, :fr).should eq 'Science Fiction'
    genre.get_localized_attribute(:name, 'FR').should eq 'Science Fiction'
  end

  it 'does not fall back when the locale has translations but not for that attribute' do
    genre.name(:de).should be_nil
    genre.get_localized_attribute(:name, :de).should be_nil
  end

  it 'returns nil when the default locale has no translation for the attribute either' do
    genre.description(:fr).should be_nil
  end

  it 'still returns the translation of the requested locale when there is one' do
    genre.description(:de).should eq 'ein grossartiges Genre'
  end
end
