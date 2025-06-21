namespace :db do
  desc "Test database connection"
  task test_connection: :environment do
    begin
      puts "Testing database connection..."
      puts "DATABASE_URL present: #{ENV['DATABASE_URL'].present?}"
      puts "DATABASE_URL (masked): #{ENV['DATABASE_URL']&.gsub(/:[^:@]*@/, ':***@')}"
      
      ActiveRecord::Base.connection.execute("SELECT 1")
      puts "✓ Database connection successful"
      
      # Test each database configuration
      %w[primary cable cache queue].each do |db_name|
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
end