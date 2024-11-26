# EmbeddedLocalization CHANGE LOG

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
