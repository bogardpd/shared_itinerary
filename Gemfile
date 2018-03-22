source 'https://rubygems.org'

ruby '2.3.1'

gem 'rails', '5.0.0.1'

# Use bcrypt to hash passwords
gem 'bcrypt', '3.1.7'
# Use Bootstrap UI framework
gem 'bootstrap-sass', '3.2.0.0'
# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '2.5.3'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '2.3.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '0.4.0', group: :doc
# Use redcarpet for markdown formatting
gem 'redcarpet'

# Force loofah to 2.2.1 for security update.
# https://github.com/flavorjones/loofah/issues/144
gem 'loofah', '~> 2.2.1'

group :development, :test do
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3', '1.3.9'
  
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '3.4.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '1.1.3'

  gem 'sql_queries_count'
end

group :test do
  gem 'minitest-reporters', '1.0.5'
  gem 'mini_backtrace', '0.1.3'
  gem 'guard-minitest', '2.3.1'
end

group :production do
  gem 'pg', '0.18.4'
  gem 'rails_12factor', '0.0.2'
  # Use puma as the production webserver
  gem 'puma', '3.9.1'
end