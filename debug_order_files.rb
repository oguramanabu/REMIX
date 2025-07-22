#!/usr/bin/env ruby

# Debug script for Order file display issue
# Run with: ruby debug_order_files.rb

require_relative 'config/environment'

order_id = 4
order = Order.find(order_id)

puts "=== Order #{order_id} File Debug ==="
puts "Order exists: #{order.present?}"
puts "Files attached: #{order.files.attached?}"
puts "Files count: #{order.files.count}"
puts "Files any?: #{order.files.any?}"
puts ""

puts "Debug values from form:"
puts "files.attached? = #{order.files.attached?}"
puts "files.count = #{order.files.attached? ? order.files.count : 0}"
puts ""

puts "Condition check: order.files.attached? && order.files.any?"
puts "Result: #{order.files.attached? && order.files.any?}"
puts ""

if order.files.attached? && order.files.any?
  puts "Files should be displayed:"
  order.files.each_with_index do |file, index|
    puts "  #{index + 1}. #{order.display_filename(file)} (#{file.byte_size} bytes)"
    puts "     Original: #{file.filename}"
    puts "     Blob ID: #{file.blob.id}"
  end
else
  puts "Files should NOT be displayed (condition failed)"
end

puts ""
puts "File metadata:"
puts order.file_metadata.inspect

puts ""
puts "Attachment URLs:"
puts order.attachment_urls.inspect
