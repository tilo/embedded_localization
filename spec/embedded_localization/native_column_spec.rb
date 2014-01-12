# encoding: utf-8
require 'spec_helper'

I18n.locale = :en

# e.g. the model "Movie" has :title as a translated field,
#      but also has :title as a native attribute for the model.

describe 'model has translated field with attribute of that same name' do
  let(:movie){ Movie.new }
  let(:title_en){ "Blade Runner" }
  let(:title_ru){'аЕЦСЫХИ ОН КЕГБХЧ'}
  let(:title_tr){"Ölüm takibi"}
  let(:title_de){"Der Blade Runner"}
  let(:blade_runner){ Movie.new(:title => title_en) }

  it 'reports it translates' do
    Movie.translates?.should be_true
  end

  it 'correctly reports the list of translated_attributes' do
    Movie.translated_attributes.sort.should eq [:description, :title]
  end

  it 'correctly reports the list of translated_attribute_names' do
    Movie.translated_attribute_names.sort.should eq [:description, :title]
  end

  it 'correcty shows the translated attribute as translated' do
    Movie.translated?(:title).should be_true
    Movie.translated?(:description).should be_true
  end

  it 'correcty shows not translated attribute' do
    Movie.translated?(:other).should be_false
  end

  it 'correctly reports translated_locales for new record' do
    movie.translated_locales.should eq [I18n.default_locale]
  end

  it 'correctly reports translation_missing for new record' do
    movie.translation_missing.should be_true
  end

  it 'creates the accessor methods' do
    movie.methods.should include(:title)
    movie.methods.should include(:title=)
    movie.methods.should include(:description)
    movie.methods.should include(:description=)
  end

  it 'correctly reports translated field for new record for default locale' do
    movie.title.should be_nil
    movie.description.should be_nil
    movie.description( I18n.default_locale ).should be_nil
  end

  it 'correctly reports translated field for new record for other locale' do
    movie.title(:ko).should be_nil
    movie.description(:de).should be_nil
  end

  it 'correctly reports translation_coverage for new record' do
    movie.translation_coverage.should eq Hash.new
  end

  it 'correctly reports translation_goverate for attributes of new record' do
    movie.translation_coverage(:title).should eq []
    movie.translation_coverage(:description).should eq []
  end

  it 'translated_coverage returns nil for not-translated attributes' do
    movie.translation_coverage(:other).should be_nil
  end

  it 'correctly reports translation_missing for new record' do
    movie.translation_missing.should == {:description=>[:en], :title=>[:en]}
    movie.translation_missing(:title).should eq [:en]
    movie.translation_missing(:description).should eq [:en]
  end

  # when setting all fields in the default locale's languange:
  it 'correctly reports translation_missing for updated record' do
    movie.title = title_en
    movie.description = "an awesome movie"
    movie.save
    movie.translation_missing.should eq Hash.new
    movie.translation_missing(:title).should eq nil
    movie.translation_missing(:description).should eq nil
  end

  it 'correctly reports translated_coverage for updated record' do
    movie.title = title_en
    movie.description = "an awesome movie"
    movie.save
    movie.translation_coverage.should == {:title=>[:en], :description=>[:en]}
    movie.translation_coverage(:title).should eq [:en]
    movie.translation_coverage(:description).should eq [:en]
  end

  # when setting all fields in additional languanges:
  it 'correctly reports values, translation_coverage, translation_missing for updated record' do
    movie.title = title_en
    movie.description = "an awesome movie"
    I18n.locale = :ru
    movie.title = title_ru
    movie.set_localized_attribute(:title , :tr, title_tr)
    I18n.locale = :de
    movie.description = "ein grossartiger Film"
    I18n.locale = I18n.default_locale   # MAKE SURE you switch back to your default
    movie.save
    movie.reload
    movie.title(:en).should eq title_en
    movie.title(:tr).should eq title_tr
    movie.get_localized_attribute(:title, :ru).should eq title_ru

    # what values are actually present
    movie.translation_coverage.should == {:title=>[:en, :ru, :tr], :description=>[:en, :de]}
    movie.translation_coverage(:title).should eq [:en,:ru,:tr]
    movie.translation_coverage(:description).should eq [:en,:de]

    # what values are missing
    movie.translation_missing.should == {:description=>[:ru, :tr], :title=>[:de]}
    movie.translation_missing(:title).should eq [:de]
    movie.translation_missing(:description).should eq [:ru,:tr]
  end

  it 'can assign the translated field' do
    movie.title = title_en
    movie.save.should be_true
    movie.title.should eq  title_en
  end

  it 'correctly shows the attribute for new record' do
    blade_runner.title.should eq title_en
  end

end
