# Debug script to check for duplicate file attachments
order_id = 14  # Change this to the order ID you're checking

order = Order.find(order_id)
puts "Order ##{order.id} has #{order.files.count} files attached:"
puts

# Group files by filename
file_groups = order.files.group_by(&:filename)

file_groups.each do |filename, files|
  if files.count > 1
    puts "DUPLICATE: '#{filename}' appears #{files.count} times:"
    files.each_with_index do |file, index|
      puts "  #{index + 1}. Blob ID: #{file.blob.id}, Size: #{file.byte_size} bytes, Created: #{file.blob.created_at}"
    end
    puts
  else
    puts "OK: '#{filename}' appears once"
  end
end

# Check if all files have unique blob IDs
blob_ids = order.files.map { |f| f.blob.id }
if blob_ids.uniq.count != blob_ids.count
  puts "\nWARNING: Some files share the same blob ID!"
else
  puts "\nAll files have unique blob IDs"
end

# Option to remove duplicates (uncomment to use)
# puts "\nDo you want to remove duplicate files? (yes/no)"
# if gets.chomp.downcase == 'yes'
#   file_groups.each do |filename, files|
#     if files.count > 1
#       # Keep the first one, remove the rest
#       files[1..-1].each do |file|
#         file.purge
#         puts "Removed duplicate: #{filename}"
#       end
#     end
#   end
#   puts "Duplicates removed!"
# end
