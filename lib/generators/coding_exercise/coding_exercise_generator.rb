class CodingExerciseGenerator < Rails::Generators::NamedBase
  require "bundler"
  Bundler.require(:tasks)
  require "active_support/core_ext/string/indent"

  source_root File.expand_path('../templates', __FILE__)

  class UnknownExerciseError < StandardError; end

  def do_the_things
    case file_name
    when "2", "second"
      set_up_second_exercise
    when "3", "third"
      set_up_third_exercise
    else
      raise UnknownExerciseError
    end
  end

  private

  def set_up_second_exercise
    puts "Setting up exercise 2!"

    # add geokit gem
    gem "geokit-rails", version: "2.3.0"

    # bundle
    Bundler.with_clean_env do
      run "bundle install"
    end

    # run the configuration installer
    generate "geokit_rails:install"

    # use the google maps geocoder
    %w(client_id cryptographic_key channel).each do |key|
      gsub_file "config/initializers/geokit_config.rb",
        "# Geokit::Geocoders::GoogleGeocoder.#{key} = ''",
        "Geokit::Geocoders::GoogleGeocoder.#{key} = nil"
    end

    # fall back to us/ca geocoders
    %w(Us Ca).each do |country_code|
      gsub_file "config/initializers/geokit_config.rb",
        %r{# Geokit::Geocoders::#{country_code}Geocoder.key =.*},
        "Geokit::Geocoders::#{country_code}Geocoder.key = nil"
    end

    # fix documentation links
    gsub_file "config/initializers/geokit_config.rb",
      "# See http://www.google.com/apis/maps/signup.html",
      "# See https://developers.google.com/maps/documentation/geocoding/get-api-key"

    gsub_file "config/initializers/geokit_config.rb",
      "# and http://www.google.com/apis/maps/documentation/#Geocoding_Examples",
      "# and https://developers.google.com/maps/documentation/geocoding/start"

    gsub_file "config/initializers/geokit_config.rb",
      "# Geokit::Geocoders::provider_order = [:google,:us]",
      "Geokit::Geocoders::provider_order = [:ca, :google, :us]"

    # copy tests over
    inject_into_file "test/controllers/api/trucks_controller_test.rb", after: "# EXERCISE 2 - DO NOT DELETE THIS LINE" do
      "\n\n" + load_tests(:exercise_2).indent(2)
    end
  end

  def load_tests(name)
    File.read(File.expand_path("#{name}_tests.rb", self.class.source_root))
  end

  def set_up_third_exercise
    puts "Setting up exercise 3!"

    gem "timecop", group: :test, version: "0.9.1"

    # bundle
    Bundler.with_clean_env do
      run "bundle install"
    end

    # copy tests over
    inject_into_file "test/controllers/api/trucks_controller_test.rb", after: "# EXERCISE 3 - DO NOT DELETE THIS LINE" do
      "\n\n" + load_tests(:exercise_3).indent(2)
    end
  end
end
