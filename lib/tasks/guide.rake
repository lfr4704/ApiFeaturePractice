require "pidfile"

include ExercisePidFileManager

Rake::TaskManager.record_task_metadata = true

desc "Start the exercises!"
task :start => ["guide:welcome", "guide:exercise1:start"]

desc "Print the current exercise's instructions"
task :help => ["guide:current", "guide:current_instructions", "guide:generic_help"]

desc "Commit your work and move on to the next exercise"
task :next => ["check", "guide:next"]

desc "Checks the status of the exercise"
task :check => ["guide:current", "db:test:prepare"] do
  sh "bin/rake test" do |ok, response|
    unless ok || ENV["FORCE"] == "true"
      sep
      para <<-EOS
        Looks like there's still at least one failing test. Once all tests
        are passing, you can move on to the next exercise.
      EOS
      exit response.exitstatus
    end
  end

  sep
  puts "\nYou're good to go! Run `rake next` to move to the next exercise."
end

namespace :guide do
  task :welcome do
    require_nothing_started

    puts <<-EOS

    ███████╗ ██╗████████╗ ██████╗ ██████╗ ██╗   ██╗██████╗
    ██╔════╝ ██║╚══██╔══╝██╔════╝ ██╔══██╗██║   ██║██╔══██╗
    ██║  ███╗██║   ██║   ██║  ███╗██████╔╝██║   ██║██████╔╝
    ██║   ██║██║   ██║   ██║   ██║██╔══██╗██║   ██║██╔══██╗
    ╚██████╔╝██║   ██║   ╚██████╔╝██║  ██║╚██████╔╝██████╔╝
     ╚═════╝ ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═════╝

    EOS

    para <<-EOS
      Today you'll be working on the REST API for a food truck tracking
      application called GitGrub. For each step, we'll provide a basic endpoint
      with some failing tests to get you started. (While you're making those
      pass, feel free to add your own!)

      Your database will be seeded with some example food trucks for you to use
      while testing your changes in development. Please familiarize yourself
      with the schema before you begin.

      You'll start the exercise by getting your development environment
      running, installing dependencies and initializing a database. We've
      provided a setup script to do this for you.
    EOS

    if ask("Would you like to run it now?")
      sh "bin/setup"
    end
  end

  task :generic_help do
    sep
    puts "\nAvailable commands:\n\n"

    unless current_exercise
      puts "bin/rake start:\t" + Rake::Task[:start].comment
    end

    if current_exercise
      puts "bin/rake check:\t" + Rake::Task[:check].comment
      puts "bin/rake next:\t" + Rake::Task[:next].comment
    end

    puts "bin/rake help:\t" + Rake::Task[:help].full_comment
  end

  task :current do
    if current = current_exercise
      puts "Currently working on #{human_name(current)}."
    else
      if ask("It looks like you haven't started the exercise yet. Would you like to begin?")
        Rake::Task[:start].invoke
        exit 0
      end
      exit 1
    end
  end

  task :current_instructions do
    if current = current_exercise
      Rake::Task["guide:#{current}:instructions"].invoke
    end
  end

  task :next do
    if current = current_exercise
      Rake::Task["guide:#{current}:finish"].invoke
    end
  end

  namespace :exercise1 do
    task :instructions do
      unless started?(:exercise1)
        para "Whoops! You can only print instructions for an exercise you have started."
        exit 1
      end

      puts <<-EOS

  ███████╗██╗  ██╗███████╗██████╗  ██████╗██╗███████╗███████╗     ██╗
  ██╔════╝╚██╗██╔╝██╔════╝██╔══██╗██╔════╝██║██╔════╝██╔════╝    ███║
  █████╗   ╚███╔╝ █████╗  ██████╔╝██║     ██║███████╗█████╗      ╚██║
  ██╔══╝   ██╔██╗ ██╔══╝  ██╔══██╗██║     ██║╚════██║██╔══╝       ██║
  ███████╗██╔╝ ██╗███████╗██║  ██║╚██████╗██║███████║███████╗     ██║
  ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝╚══════╝╚══════╝     ╚═╝

      EOS

      para <<-EOS
        We'd like to give our API consumers the ability to rate trucks. We've
        provided a `POST /trucks/1/ratings` endpoint and some tests to get you
        started.  Some things to keep in mind:
      EOS

      puts <<-EOS

  * A user can only rate each truck once
  * Valid ratings are whole numbers from 1-5 (5 being highest)
  * Ratings should be persisted in the database, but the storage model is
    up to you
      EOS

      para <<-EOS
        Once ratings can be created, modify the `GET /trucks/1` endpoint to
        return a truck's average rating, rounded to the nearest half (e.g. an
        average rating of 4.3 rounds to 4.5).

        Hint: `rake test` will run the tests.
      EOS
    end

    task :set_pid do
      if ask("Ready to get started?")
        puts "Starting Exercise 1..."
        start(:exercise1)
      end
    end

    task :start => [:set_pid, :instructions]

    task :finish => [:check] do
      if ENV["SKIP_COMMIT"] == "true"
        finish(:exercise1)
        Rake::Task["guide:exercise2:start"].invoke
      elsif ask("Ready to commit your work?")
        sh "git add ."
        sh "git commit -a --allow-empty -m 'Marking Exercise 1 Complete'" do |ok, response|
          if ok
            finish(:exercise1)
            Rake::Task["guide:exercise2:start"].invoke
          else
            para <<-EOS
              Something went wrong with that commit. Please commit your work
              and try again.
            EOS
          end
        end
      end
    end
  end

  namespace :exercise2 do
    task :set_pid do
      puts "Starting Exercise 2..."
      start(:exercise2)
    end

    task :start => [:set_pid, :setup, :instructions]

    task :instructions do
      unless started?(:exercise2)
        para "Whoops! You can only print instructions for an exercise you have started."
        exit 1
      end

      puts <<-EOS

  ███████╗██╗  ██╗███████╗██████╗  ██████╗██╗███████╗███████╗    ██████╗
  ██╔════╝╚██╗██╔╝██╔════╝██╔══██╗██╔════╝██║██╔════╝██╔════╝    ╚════██╗
  █████╗   ╚███╔╝ █████╗  ██████╔╝██║     ██║███████╗█████╗       █████╔╝
  ██╔══╝   ██╔██╗ ██╔══╝  ██╔══██╗██║     ██║╚════██║██╔══╝      ██╔═══╝
  ███████╗██╔╝ ██╗███████╗██║  ██║╚██████╗██║███████║███████╗    ███████╗
  ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝╚══════╝╚══════╝    ╚══════╝

      EOS

      para <<-EOS
        Using the geokit gem and configured geocoders, add the ability to:
      EOS

      puts <<-EOS
  * set a truck's last known location
  * get a truck's distance from a point
      EOS

      para <<-EOS
        We've added some tests for you to exercise these features, updating the
        truck's last known location in `PATCH /trucks/1` and sending an optional
        `near` parameter to the `GET /trucks/1` request to get the distance
        back in the response.

        We'd like you to return the distance in miles, rounded to 2 decimal
        places. Keep in mind that some trucks won't have a last known location!
      EOS
    end

    task :setup do
      sh "bin/rails g coding_exercise 2"
    end

    task :finish => [:check] do
      if ENV["SKIP_COMMIT"] == "true"
        finish(:exercise2)
        Rake::Task["guide:exercise3:start"].invoke
      elsif ask("Ready to commit your work?")
        sh "git add ."
        sh "git commit -a --allow-empty -m 'Marking Exercise 2 Complete'" do |ok, response|
          if ok
            finish(:exercise2)
            Rake::Task["guide:exercise3:start"].invoke
          else
            para <<-EOS
              Something went wrong with that commit. Please commit your work
              and try again.
            EOS
          end
        end
      end
    end
  end

  namespace :exercise3 do
    task :set_pid do
      puts "Starting Exercise 3..."
      start(:exercise3)
    end

    task :start => [:set_pid, :setup, :instructions]

    task :setup do
      sh "bin/rails g coding_exercise 3"
    end

    task :instructions do
      unless started?(:exercise3)
        para "Whoops! You can only print instructions for an exercise you have started."
        exit 1
      end

      puts <<-EOS

  ███████╗██╗  ██╗███████╗██████╗  ██████╗██╗███████╗███████╗    ██████╗
  ██╔════╝╚██╗██╔╝██╔════╝██╔══██╗██╔════╝██║██╔════╝██╔════╝    ╚════██╗
  █████╗   ╚███╔╝ █████╗  ██████╔╝██║     ██║███████╗█████╗       █████╔╝
  ██╔══╝   ██╔██╗ ██╔══╝  ██╔══██╗██║     ██║╚════██║██╔══╝       ╚═══██╗
  ███████╗██╔╝ ██╗███████╗██║  ██║╚██████╗██║███████║███████╗    ██████╔╝
  ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝╚══════╝╚══════╝    ╚═════╝

      EOS

      para <<-EOS
        Add the ability for API consumers to search for trucks by minimum
        rating, whether they are open right now, and associated tags. Sample
        tags are provided in the seed data. All search criteria must be met, so
        use AND logic.
      EOS
    end

    task :finish => [:check] do
      if ENV["SKIP_COMMIT"] == "true"
        finish(:exercise3)
        # TODO - output something exciting
      elsif ask("Ready to commit your work?")
        sh "git add ."
        sh "git commit -a --allow-empty -m 'Marking Exercise 3 Complete'" do |ok, response|
          if ok
            finish(:exercise3)
          else
            para <<-EOS
              Something went wrong with that commit. Please commit your work
              and try again.
            EOS
          end
        end
      end
    end
  end
end

def ask(question)
  puts "\n"
  puts question + " (y/n)"

  begin
    input = STDIN.gets.strip.downcase
  end until %w(q quit y yes n no).include?(input)

  bye if %w(quit q).include?(input)

  %w(y yes).include?(input)
end

def paragraph(str)
  puts "\n"
  str.split(/(\n\r?){2}/).each(&:strip!).each do |p|
    puts wrap(p.gsub(/\s+/, " "))
  end
end
alias :para :paragraph

def wrap(str, width: ideal_width)
  str.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
end

def ideal_width
  @terminal_width ||= `tput cols`
  [78, @terminal_width.strip.to_i].min
end

def sep
  puts ""
  puts "/" * ideal_width
end

def bye(message = nil)
  para message if message
  puts "Bye!"
  exit 0
end
