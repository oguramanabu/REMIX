#!/usr/bin/env ruby

# Debug test for file display issue on order edit page
# Run with: ruby debug_file_display_test.rb

require_relative 'config/environment'
require 'capybara'
require 'selenium-webdriver'

# Configure Capybara
Capybara.default_driver = :selenium_chrome_headless
Capybara.javascript_driver = :selenium_chrome_headless
Capybara.server = :puma, { Silent: true }

# Create a test session
session = Capybara::Session.new(:selenium_chrome_headless)

begin
  # Start the Rails server in the background if not running
  # We'll use the existing server on port 3000
  session.visit 'http://localhost:3000'

  puts "=== Debugging Order Edit Page File Display ==="

  # Login with an existing user
  session.fill_in 'Email address', with: 'a@a.com'
  session.fill_in 'Password', with: 'password'  # assuming default password
  session.click_button 'Sign in'

  sleep 1

  # Navigate to order edit page
  puts "Navigating to /orders/4/edit..."
  session.visit 'http://localhost:3000/orders/4/edit'

  sleep 2

  puts "Current URL: #{session.current_url}"
  puts "Page Title: #{session.title}"

  # Check for debug info
  debug_box = session.find('.border.p-2.rounded', text: 'Debug:', wait: 5)
  if debug_box
    puts "\n=== DEBUG BOX CONTENT ==="
    puts debug_box.text
  else
    puts "DEBUG BOX NOT FOUND!"
  end

  # Check for current files section
  if session.has_text?('現在のファイル:', wait: 5)
    puts "\n=== CURRENT FILES SECTION FOUND ==="
    current_files_section = session.find('p', text: '現在のファイル:')
    # Find parent container and get all file items
    parent = current_files_section.find(:xpath, '..')
    files = parent.all('.existing-file')
    puts "Found #{files.count} existing files:"
    files.each_with_index do |file, index|
      puts "  #{index + 1}. #{file.text}"
    end
  else
    puts "\n=== CURRENT FILES SECTION NOT FOUND ==="
    puts "Checking if the condition block is present..."
    if session.has_css?('.existing-file', wait: 2)
      puts "Found .existing-file elements!"
    else
      puts "No .existing-file elements found"
    end
  end

  # Take a screenshot
  screenshot_path = Rails.root.join('debug_screenshot.png')
  session.save_screenshot(screenshot_path)
  puts "\nScreenshot saved to: #{screenshot_path}"

  # Get page source and save it
  page_source_path = Rails.root.join('debug_page_source.html')
  File.write(page_source_path, session.html)
  puts "Page source saved to: #{page_source_path}"

  # Check browser console for errors
  logs = session.driver.browser.logs("browser")
  if logs.any?
    puts "\n=== BROWSER CONSOLE LOGS ==="
    logs.each do |log|
      puts "#{log['level']}: #{log['message']}"
    end
  else
    puts "\nNo console errors found"
  end

rescue Exception => e
  puts "ERROR: #{e.message}"
  puts e.backtrace.first(5)
end

puts "\n=== Debug Complete ==="
