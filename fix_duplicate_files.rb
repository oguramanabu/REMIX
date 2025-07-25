# Script to remove duplicate files from order
order_id = 14  # Change this to the order ID you want to fix

order = Order.find(order_id)
puts "Order ##{order.id} has #{order.files.count} files attached"

# Group files by filename
file_groups = order.files.group_by { |f| f.filename.to_s }

file_groups.each do |filename, files|
  if files.count > 1
    puts "\nFound #{files.count} files with name: '#{filename}'"
    puts "Keeping the first one and removing #{files.count - 1} duplicates..."

    # Keep the first file, remove the rest
    files[1..-1].each do |file|
      file.purge
    end

    puts "✓ Removed #{files.count - 1} duplicate(s)"
  end
end

puts "\nOrder now has #{order.files.reload.count} file(s) attached"
