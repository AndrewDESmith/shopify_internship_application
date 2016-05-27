require "yaml"

class Item
  attr_reader :name, :time

  def initialize(name, time)
    @name = name
    @time = time
  end

  def stringify
    "Item: #{@name} @ #{@time.to_s}"
  end
end

class Todo < Item
  attr_reader :items, :file_name

  def initialize(file_name)
    # Cannot access file_name and items as symbols in other methods (faulty syntax).
    @file_name = file_name
    @items = []
    open()
  end

  # Use YAML file format to allow previously made lists to be called up at program run time.
  def open
    @items = YAML.load_file("#{@file_name}.yml") if File.exist?("#{@file_name}.yml")
  end

  # Save the YAML file when any change is made to the list (addition, removal, or clearing of list items).
  def save
    File.open("#{@file_name}.yml", "w") { |f| f.write(@items.to_yaml) }
  end

  def add(item)
    item = Item.new(item, Time.now)
    puts "\n" + "Adding #{item.stringify}"
    @items.push(item)
    File.open(@file_name, "w") do |f|
      @items.each_with_index { |item, index| f.puts("#{index + 1}: " + item.stringify) }
    end
    save()
    # Returning items from the add, remove, and clear methods is unnecessary.
  end

  def remove(index)
    # Ensure that the item requested for removal exists.
    if !@items[index.to_i - 1].nil?
      puts "\n" + "Removing " + @items[index.to_i - 1].stringify + " on line #{index.to_i}"
      @items.delete_at(index.to_i - 1)
      File.open(@file_name, "w") { |f| f.write(to_s) }
      save()
    else
      puts "Item does not exist at this line number!"
    end
  end

  def clear
    puts "Clearing out all items in list"
    @items.clear
    File.open(@file_name, "w") { |f| f.write(to_s) }
    save()
  end

  def to_s
    @items.each_with_index { |item, index| "#{index + 1}: #{item.stringify}" }
  end

  # Print method for better usability.
  def print
    if @items != []
      @items.each_with_index { |item, index| puts "#{index + 1} #{item.stringify}" }
    else
      puts "The list is empty!"
    end
  end

  # Present a menu for the user.
  def options
    puts "\n" + "(1) [add] item || (2) [remove] item || (3) [print] list of items || (4) [clear] list || (5) [exit] program" +
    "\n"
  end
end

# Begin running the program.
puts "\n" + "Welcome to the Shopify Intern Inventory Application Program.  Please enter the name of the file that you would like to create or open:"
file = gets.chomp
todo = Todo.new(file)
puts "\n" + "Please enter a number (1-5) or type the [word] to select an option:"
todo.options
option = gets.chomp

# Keep running the program until the user chooses to exit.
until option == "5" || option == "exit"
  case option
  when "1", "add"
    puts "Enter an item to add: "
    add_item = gets.chomp
    todo.add(add_item)
    todo.options
    option = gets.chomp
  when "2", "remove"
    puts "Enter an item's line number to remove the item from the list."
    remove_item = gets.chomp
    todo.remove(remove_item)
    todo.options
    option = gets.chomp
  when "3", "print"
    puts "List items:"
    todo.print
    todo.options
    option = gets.chomp
  when "4", "clear"
    todo.clear
    todo.options
    option = gets.chomp
  else
    puts "Invalid entry."
    todo.options
    option = gets.chomp
  end
end
