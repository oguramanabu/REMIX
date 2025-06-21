namespace :db do
  desc "Test database connection and show environment variables"
  task test_connection: :environment do
    begin
      puts "Testing database connection..."
      puts "DATABASE_URL present: #{ENV['DATABASE_URL'].present?}"
      puts "DATABASE_URL (masked): #{ENV['DATABASE_URL']&.gsub(/:[^:@]*@/, ':***@')}"
      
      # Show individual environment variables
      puts "\nIndividual Database Environment Variables:"
      puts "REMIX_DATABASE_HOST: #{ENV['REMIX_DATABASE_HOST']}"
      puts "REMIX_DATABASE_NAME: #{ENV['REMIX_DATABASE_NAME']}"
      puts "REMIX_DATABASE_USERNAME: #{ENV['REMIX_DATABASE_USERNAME']}"
      puts "REMIX_DATABASE_PASSWORD: #{ENV['REMIX_DATABASE_PASSWORD'].present? ? '***' : 'not set'}"
      puts "REMIX_DATABASE_PORT: #{ENV['REMIX_DATABASE_PORT'] || '5432 (default)'}"
      
      puts "\nTesting primary database connection..."
      ActiveRecord::Base.connection.execute("SELECT 1")
      puts "✓ Primary database connection successful"
      
      # Test each database configuration
      %w[cable cache queue].each do |db_name|
        puts "Testing #{db_name} database..."
        ActiveRecord::Base.connected_to(database: { writing: db_name.to_sym }) do
          ActiveRecord::Base.connection.execute("SELECT 1")
          puts "✓ #{db_name} database connection successful"
        end
      rescue => e
        puts "✗ #{db_name} database connection failed: #{e.message}"
      end
      
    rescue => e
      puts "✗ Database connection failed: #{e.message}"
      puts "Error class: #{e.class}"
      puts "Backtrace:"
      puts e.backtrace.first(5)
    end
  end
  
  desc "Parse DATABASE_URL and show individual components"
  task parse_database_url: :environment do
    database_url = ENV['DATABASE_URL']
    if database_url.present?
      require 'uri'
      begin
        uri = URI.parse(database_url)
        puts "Parsed DATABASE_URL components:"
        puts "Host: #{uri.host}"
        puts "Port: #{uri.port}"
        puts "Database: #{uri.path[1..-1]}" # Remove leading slash
        puts "Username: #{uri.user}"
        puts "Password: #{uri.password.present? ? '***' : 'not set'}"
        
        puts "\nTo set as individual environment variables:"
        puts "REMIX_DATABASE_HOST=#{uri.host}"
        puts "REMIX_DATABASE_PORT=#{uri.port}"
        puts "REMIX_DATABASE_NAME=#{uri.path[1..-1]}"
        puts "REMIX_DATABASE_USERNAME=#{uri.user}"
        puts "REMIX_DATABASE_PASSWORD=#{uri.password}"
      rescue => e
        puts "Error parsing DATABASE_URL: #{e.message}"
      end
    else
      puts "DATABASE_URL not set"
    end
  end
end