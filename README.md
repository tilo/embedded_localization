# Embedded Localization

[![codecov](https://codecov.io/gh/tilo/embedded_localization/graph/badge.svg?token=MX3ULB0S1Y)](https://codecov.io/gh/tilo/embedded_localization) [![Gem Version](https://badge.fury.io/rb/embedded_localization.svg)](http://badge.fury.io/rb/embedded_localization)

`embedded_localization` is compatible with Rails 6.x, 7.x, and adds model translations to ActiveRecord.  `embedded_localization` is compatible with and builds on the new [I18n API in Ruby on Rails](http://guides.rubyonrails.org/i18n.html)

`embedded_localization` is very lightweight, and allows you to transparently store translations of attributes right inside each record — no extra database tables needed to store the localization data! Make sure that your database default encoding is UTF-8 or UFT-16.

Model translations with `embedded_localization` use default ActiveRecord features and do not limit any ActiveRecord functionality.

On top of that, you also get tools for checking into which locales an attribute was translated to, as well as for checking overall translation coverage.


## Motivation

One real-life scenario is that you have a SaaS system which needs custom text for each company, which also needs to be translated in to several languages. Another scenario is that you have dynamic content that needs to be translated.

A recent project needed some localization support for ActiveRecord model data, but I did not want to clutter the schema with one additional table for each translated model, as the globalize gem requires.  A second requirement was to allow SQL queries of the fields using the default locale.

The advantage of EmbeddedLocalization is that it does not need extra tables, and therefore no joins or additional table lookups to get to the translated data.

If your requirements are different, this approach might not work for you. In that case, I recommend to look at the alternative solutions listed at the bottom of this page.


## Requirements

* ActiveRecord >= 6  # including 7.x
* [I18n](http://guides.rubyonrails.org/i18n.html)

## Installation

To install Embedded_Localization, use:

	  $ gem install embedded_localization


## Translated Models

Adding localization to a table is very simple. Just add a text field named `i18n` to the table, and you are ready to go!  This allows you to add translated fields via the helper method `translates` in the model.

Optionally, you can also keep a DB field with the same name as the translated field, which will store the values for the `I18n.default_locale`.

Model translations allow you to translate your models’ attribute values. The attribute type needs to be string or text.

### Example 1

Let's assume you have a table for movie genres, and you want to translate the names and the descriptions of the genres.   Simply define your `Genre` model as follows:

```ruby
class Genre < ActiveRecord::Base
  translates :name, :description
end
```

In the DB migration, you just need to add the `i18n` text field:

```ruby
class CreateGenres < ActiveRecord::Migration
  def self.change
    create_table :genres do |t|
      t.text   :i18n	# stores ALL the translated attributes; persisted as a Hash

      t.timestamps
    end
  end
end
```

### Example 2

Obviously you can't do SQL queries against tanslated fields which are stored in the `i18n` text field.
To eliviate this problem, you can also define a normal DB attribute with the same name as your translated attribute, and it will store the value for your `I18n.default_locale`.

This way you can always do SQL queries against the values in the `I18n.default_locale`.

To do this, using the same model as in example 1, you can modify your migration as follows:

```ruby
class CreateGenres < ActiveRecord::Migration
  def self.change
    create_table :genres do |t|
      t.text   :i18n	# stores the translated attributes; persisted as a Hash

      t.string :name  # allows us to do SQL queries

      t.timestamps
    end
  end
end
```

# Usage

In your code you can modify the values of your translated attributes in two ways.

## Using Setters / Getters

Using the built-in getter/setter methods you can set the values for any locale directly, even though
you are using your own locale.

```ruby
I18n.locale = :en
g = Genre.first
g.name = 'science fiction'

# even though you are using the :en locale, you can still set the values for other locales:

g.set_localized_attribute( :name, :jp, "サイエンスフィクション" )
g.set_localized_attribute( :name, :ko, "공상 과학 소설" )

g.name       # => 'science fiction'
g.name(:jp)  # => "サイエンスフィクション"
g.name(:ko)  # => "공상 과학 소설"

g.get_localized_attribute( :name, :jp )  # => "サイエンスフィクション"
g.get_localized_attribute( :name, :ko )  # => "공상 과학 소설"
```

## Tweaking `I18n.locale`

By manipulating the `I18n.locale`. This is what happens if you have user's with different locales entering values into a database.

The controller is just assigning the new value via `name=` , but `embedded_localization` gem takes care of storing it for the correct given locale.

```ruby
I18n.locale = :en
g = Genre.first
g.name  # => 'science fiction'

I18n.locale = :jp
g.name = "サイエンスフィクション"

I18n.locale = :ko
g.name = "공상 과학 소설"
g.name  # => "공상 과학 소설"

I18n.locale = :jp
g.name  # => "サイエンスフィクション"

I18n.locale = :en  # MAKE SURE to switch back to your default locale if you tweak it
```

## SQL Queries against Translated Fields

Old `embedded_localization` implementations < 0.2.0 had the drawback that you can not do SQL queries on translated attributes.

To eliminate this limitation, you can now define any translated attribute as a first-class database column in your migration.

If you define a translated attribute as a column, `embedded_localization` will store the attribute value for I18n.default_locale in that column, so you can search for it.

After defining the column, and running the migration, you need to populate the column initially. It will auto-update every time you write while you are using I18n.default_locale .

See also Example 2 above.

```ruby
I18n.locale = :en
g = Genre.first
g.name = 'science fiction'   # in Example 2 this will be stored in the DB column :name as well
# ...
g.set_localized_attribute( :name, :jp, "サイエンスフィクション" )
# ...
scifi = Genre.where(:name => "science fiction").first
```

Limitation: You can not search for the translated strings other than for your default locale.


## Data Migration


Existing data can be migrated from an existing (not-translated) column, into a translated column with the same name as follows:

```ruby
Genre.record_timestamps = false   # to not modify your existing timestamps
Genre.all.each do |g|
  g.name = g.name   # the right-hand-side fetches the translation from the i18n attribute hash
  g.save			# saves the :name attribute without updating the updated_at timestamp
end
Genre.record_timestamps = true
```

## I18n fallbacks for empty translations

It is possible to enable fallbacks for empty translations. It will depend on the configuration setting you have set for I18n translations in your Rails config, or you can enable fallback when you define the translation fields. Currently we only support fallback to `I18n.default_locale`

You can enable them by adding the next line to `config/application.rb` (or only `config/environments/production.rb` if you only want them in production)

```ruby
config.i18n.fallbacks = true # falls back to I18n.default_locale
```

By default, `embedded_localization` will only use fallbacks when the translation value for the item you've requested is `nil`.

```ruby
class Genre < ActiveRecord::Base
  translates :name, :description # , :fallbacks => true
end

I18n.locale = :en
g = Genre.first
g.name  # => 'science fiction'

I18n.locale = :jp
g.name  # => "サイエンスフィクション"

I18n.locale = :de
g.name  # => nil

I18n.fallbacks = true
I18n.locale = :de
g.name  # => 'science fiction'
```

## Want some Candy?

It's nice to have the values of attributes be set or read with the current locale, but `embedded_localization` offers you a couple of additional features, which can come in handy.

### Class Methods

Each class which uses `embedded_localization` will have these additional methods defined:

* Klass.translated_attributes
* Klass.translated?
* Klass.fallbacks?

e.g.:

```ruby
Genre.translated_attributes # => [:name,:description]
Genre.translated?  # => true
Genre.fallbacks?  # => false
```

### Instance Methods

Each model instance of a class which uses `embedded_localization` will have these additional features:

  * on-the-fly translations, via `g.name(:locale)`
  * list of translated locales
  * list of translated attributes
  * hash of translation coverage for a given record's attributes or a particular attribute
  * hash of missing translations for a given record's attributes or a particular attribute
  * directly setting and getting attribute values for a given locale; without having to change `I18n.locale`

e.g.:

```ruby
g = Genre.where(:name => "science fiction").first

# check if an attribute is translated:
g.translated?(:name) # => true

# which attributes are translated?
g.translated_attributes   # => [:description, :name]

# check for which locales we have values: (spanning all translated fields)
g.translated_locales  # => [:en]

g.set_localized_attribute(:description, :de, "Ich liebe Science Fiction Filme")

# check again for which locales we have values: (spanning all translated fields)
g.translated_locales  # => [:en, :de]

# show details for which locales the attributes have values for:
#   for all attributes:
g.translation_coverage  # => {:name=>[:en], :description=>[:de]}

#   for a specific attribute:
g.translation_coverage(:name) # => [:en]
g.translation_coverage(:description)  # => [:de]

# show where translations are missing:
#   for all attributes:
g.translation_missing   # => {:description=>[:en], :name=>[:de]}

#   for a specific attribute:
g.translation_missing(:name)  # => [:de]
g.translation_missing(:description)  # => [:en]
```

#### translated_locales vs translation_coverage

##### translated_locales

`translated_locales` lists the super-set of all locales, including the default locale, even if there is no value set for a specific attribute.
For a new empty record, this will report `I18n.default_locale`.

`translated_locales` reports which translations / languages are possible.

##### translation_coverage

`translation_coverage` only lists locales for which a non-nil value is set.
For a new empty record, this will be empty.

`translation_coverage` reports for which languages translations exist (actual values exist).

##### Example

```ruby
I18n.locale = :jp
g = Genre.first
g.name  # => "サイエンスフィクション"

g.name(:en)  # => 'science fiction'
g.name(:ko)  # => "공상 과학 소설"
g.name(:de)  # => nil

g.translated_locales  # => [:en,:jp,:ko]
g.translated_attributes # => [:name,:description]
g.translated?  # => true

g.translation_coverage
# => {"name"=>["en", "ko", "jp"] , "description"=>["en", "de", "fr", "ko", "jp", "es"]}

g.translation_coverage(:name)
# => {"name"=>["en", "ko", "jp"]}

g.translation_missing
# => {"name"=>["de", "fr", "es"]}

g.translation_missing(:display)
# => {}     # this indicates that there are no missing translations for the :display attribute

g.get_localized_attribute(:name, :de)
# => nil

g.set_localized_attribute(:name, :de, "Science-Fiction")
# => "Science-Fiction"
```

## [CHANGELOG](CHANGELOG.md)

## Alternative Solutions

* [Mongoid](https://github.com/mongoid/mongoid) - awesome Ruby ORM for MongoDB, which includes in-table localization of attributes (mongoid >= 2.3.0)
* [Globalize](https://github.com/globalize/globalize) - is an awesome gem, but different approach with more tables in the schema.
* [Veger's fork of Globalize2](http://github.com/veger/globalize2) - uses default AR schema for the default locale, delegates to the translations table for other locales only
* [TranslatableColumns](http://github.com/iain/translatable_columns) - have multiple languages of the same attribute in a model (Iain Hecker)
* [localized_record](http://github.com/glennpow/localized_record) - allows records to have localized attributes without any modifications to the database (Glenn Powell)
* [model_translations](http://github.com/janne/model_translations) - Minimal implementation of Globalize2 style model translations (Jan Andersson)

## Related Solutions

* [globalize2_versioning](http://github.com/joshmh/globalize2_versioning) - acts_as_versioned style versioning for globalize2 (Joshua Harvey)
* [i18n_multi_locales_validations](http://github.com/ZenCocoon/i18n_multi_locales_validations) - multi-locales attributes validations to validates attributes from globalize2 translations models (Sébastien Grosjean)
* [globalize2 Demo App](http://github.com/svenfuchs/globalize2-demo) - demo application for globalize2 (Sven Fuchs)
* [migrate_from_globalize1](http://gist.github.com/120867) - migrate model translations from Globalize1 to globalize2 (Tomasz Stachewicz)
* [easy_globalize2_accessors](http://github.com/astropanic/easy_globalize2_accessors) - easily access (read and write) globalize2-translated fields (astropanic, Tomasz Stachewicz)
* [globalize2-easy-translate](http://github.com/bsamman/globalize2-easy-translate) - adds methods to easily access or set translated attributes to your model (bsamman)
* [batch_translations](http://github.com/alvarezrilla/batch_translations) - allow saving multiple globalize2 translations in the same request (Jose Alvarez Rilla)





