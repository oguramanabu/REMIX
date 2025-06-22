#!/usr/bin/env bash
# Exit on error
set -o errexit

echo "DATABASE_URL (masked): $(echo $DATABASE_URL | sed 's/:[^:@]*@/:***@/')"

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Test database connection before migrations
echo "Testing database connection..."
bundle exec rails runner "puts 'Database connection test'; ActiveRecord::Base.connection.execute('SELECT 1'); puts 'Database connection successful'"

# If you have a paid instance type, we recommend moving
# database migrations like this one from the build command
# to the pre-deploy command:
bundle exec rails db:migrate
