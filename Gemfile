source 'https://rubygems.org'

ruby '2.7.1'

gem 'rails', '~> 5.2', '>= 5.2.3'

# Use bcrypt to hash passwords
gem 'bcrypt', '~> 3.1', '>= 3.1.12'

# Use Bootstrap UI framework
gem 'bootstrap', '~> 4.1', '>= 4.1.1'
# Use SCSS for stylesheets
gem 'sassc-rails', '~> 2.0'
# Use redcarpet for markdown formatting
gem 'redcarpet'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 6.0', '>= 6.0.1'

# Use savon for SOAP
gem 'savon', '~> 2.11', '>= 2.11.1'

group :development, :test do
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3', '1.3.9'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.0', '>= 2.0.2'

  gem 'sql_queries_count'
end

group :test do
  gem 'rails-controller-testing', '~> 1.0', '>= 1.0.2'
  gem 'minitest-reporters', '~> 1.2'
  gem 'minitest-fail-fast', '~> 0.1.0'
  gem 'guard-minitest', '~> 2.4', '>= 2.4.6'
end

group :production do
  gem 'pg', '0.18.4'
  gem 'rails_12factor', '0.0.2'
  # Use puma as the production webserver
  gem 'puma', '4.3.9'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]