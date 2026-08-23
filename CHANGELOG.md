# EmbeddedLocalization CHANGE LOG

## 1.4.0 (2026-08-24)
 * new `storage:` option for `translates`: store the translations in a `json` / `jsonb` column (`storage: :json`) or in a PostgreSQL `hstore` column (`storage: :hstore`) instead of the YAML `text` column; the translated values are then queryable in SQL (see README, Example 3)
 * fallbacks now follow the chain configured in `I18n.fallbacks` (e.g. `config.i18n.fallbacks = { 'de-AT' => 'de' }`: `:"de-AT"` → `:de` → `I18n.default_locale`); `I18n.default_locale` is always the last fallback, as before
 * bug fix: fallbacks did not work for the current `I18n.locale` of a record loaded from the database, nor for a locale that had translations for other attributes; a `nil` translation now always falls back (as the README documented)
 * bug fix: with `fallbacks: true`, reading an attribute that has no translation in `I18n.default_locale` returned a Hash of nils on unsaved records instead of nil
 * bug fix: assigning a translation equal to the current value marked the record as changed on models without a DB column for that attribute (the fix for issue #4 only covered models with such a column)
 * bug fix: `set_localized_attribute(attr, locale, value)` compared against `I18n.locale` instead of `locale`; when the current locale already held the same value, the translation for `locale` was not stored
 * removed the `Hash.zip` monkey patch (`lib/extensions/hash.rb`); the gem no longer adds methods to core classes
 * CI: ActiveRecord 6.1, 7.0, 7.1, 7.2, 8.0 and 8.1 are tested against SQLite, PostgreSQL and MySQL; Ruby 2.5 through 4.0, `head` and TruffleRuby; coverage upload through `codecov/codecov-action` instead of the unmaintained `codecov` gem

## 1.3.1 (2024-11-26)
 * [Issue 14](https://github.com/tilo/embedded_localization/pull/14) Fix active support proxy object deprecation (thanks to [Romain Morlevat](https://github.com/RomainMorlevat))

## 1.3.0 (2024-11-13)
 * fixed ([issue 10](https://github.com/tilo/embedded_localization/issues)) to support Rails >= 7.1 (thanks to [Romain Morlevat](https://github.com/RomainMorlevat))
  
## 1.2.2 (2022-04-25)
* improved docs

## 1.2.0 (2017-11-10)
* Rails 5 compatibility
* fixing tests
* updating doc

## 1.1.1 (2014-11-02)
* minor update

## 1.1.0 (2014-01-12)
* adding more rspec tests.
* improving documentation and README

## 1.0.0 (2014-01-11)
* adding rspec tests.
* fixing issue #6: translated fields for new records were not nil
* fixing issue #7: translation_missing for new records is breaking


## 0.2.5 (2013-11-02)
* adding MIT and GPL-2 licenses to gem-spec file; contact me if you need another license

## 0.2.4 (2012-03-02)
* Issue #5 : bugfix for attr_writer

## 0.2.3 (2012-03-02)
* Issue #4 : bugfix for attr_writer - no longer updates attributes if value didn't change => timestamps don't change in that case

## 0.2.2 (2012-02-06)
* bugfix for attr_writer

## 0.2.1 (2012-01-31)
* bugfix for serialized i18n attribute

## 0.2.0 (2012-01-31)
* added support for having DB columns for translated attributes, to enable SQL queries in `I18n.default_locale`

## 0.1.4 (2012-01-31)
* fixed bug with dirty tracking of serialized i18n attribute
* renamed #fallback? to #fallbacks?

## 0.1.3 Initial Version (2012-01-27)
* initial version
