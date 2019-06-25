### Global Variables
$foods = []
$prices = []
$name = []
$history = []

### Classes
class Map
    attr_reader :size, :cell

    def initialize(size)
        @size = size
        @cell = []
        
        for i in (0...size)
            temp = Array.new
            for j in (0...size)
                temp.push(Cell.new)
            end
            @cell.push(temp)
        end
    end

    def assign(x, y, obj)
        #assign object to map cell
        @cell[x][y].creation = obj
    end

    def is_nil(x, y)
        #check wether cell in [x,y] nil or not
        temp = @cell[x][y]
        temp.creation == nil
    end
end

class Cell
    attr_accessor :creation

    def initialize
        @creation = nil
    end

    def render()
        if(@creation != nil)
            @creation.render
        else
            print "-"
        end
    end
end

class Creation
    attr_reader :x, :y
    def initialize(x, y)
        @x = x
        @y = y
    end
end

class Person < Creation
    attr_accessor :name
    def initialize(x, y, name)
        super(x, y)
        @name = name
    end
end

class Store < Creation
    attr_accessor :name , :foods, :prices, :num_of_foods
    def initialize(x, y, name, *menu)
        super(x, y)
        
        @name = name
        @num_of_foods = 0
        @foods = Array.new
        @prices = Array.new

        i = 0
        while i < menu.length
            @foods[@num_of_foods] = menu[i]
            @prices[@num_of_foods] = menu[i + 1]
            @num_of_foods += 1
            i = i + 2
        end
    end

    def render
        print "S"
    end

    def show_menu
        puts "Please select your order by number"
        for i in 0...@num_of_foods
            puts "#{i+1}. #{@foods[i]}  Rp.#{@prices[i]}"
        end
        puts ""
    end
end

class Driver < Person
    attr_accessor :rating
    def initialize(x, y)
        super(x, y, $name[rand($name.length)])
        @rating = 0.0
    end

    def render
        print "D"
    end
end

class User < Person
    def initialize(x, y)
        super(x, y, "User")
    end

    def render
        print "U"
    end
end

### Functions
def create_database(menu, name, history)
    begin
        File.open(menu,"r") do |str|
            while line = str.gets
                temp = line.split(/\s*@\s*/)
                $foods.push(temp[0])
                $prices.push(temp[1].to_i)
            end
        end

        File.open(name,"r") do |str|
            while line = str.gets
                $name.push(line.strip)
            end
        end

        File.open(history,"r") do |str|
            while line = str.gets
                $history.push(line.strip)
            end
        end

    rescue Exception => e
        puts e.message + "\n\n"
        exit
    end
end

def random_store(max_index)
    store_objects = []
    name = "Warung #{$name[rand($name.length)]}"
    store_objects.push(name)

    min_index = rand(max_index)
    for i in (min_index..max_index)
        store_objects.push($foods[i].strip)
        store_objects.push($prices[i].to_i)
    end

    store_objects
end

def show_help
    puts "Please select a command by inputing a number"
    puts "For example, your command: 1\n\n"
end

def execute_game(first_arg, *rest_args)
    ##Execute the Go-Eat game
    history = "history.txt"
    create_database("menu.txt", "name.txt", history)
    drivers = []
    stores = []
    
    n = nil
    gmap = nil
    user = nil


    if(first_arg.eql?("file"))
        #Create map from file
        File.open(rest_args[0],"r") do |str|
            begin
                #Create Map
                line = str.gets
                n = line.to_i
                gmap = Map.new(n)

                #Create User
                line = str.gets.split(" ")
                user = User.new(line[0].to_i,line[1].to_i)
                gmap.assign(user.x, user.y, user)
                
                p = str.gets.to_i
                for i in (0...p)
                    line = str.gets.split(" ")
                    driver_x = line[0].to_i
                    driver_y = line[1].to_i

                    driver = Driver.new(driver_x, driver_y)
                    gmap.assign(driver_x, driver_y, driver)
                    drivers.push(driver)
                end

                q = str.gets.to_i
                for i in (0...q)
                    line = str.gets.split(" ")
                    store_x = line[0].to_i
                    store_y = line[1].to_i
                    
                    store_attr = []
                    store_name = str.gets.chomp #Store name
                    r = str.gets.to_i #Store menu
                    for j in (0...r)
                        line = str.gets.split(/\s*@\s*/)
                        store_attr.push(line[0].strip) #food
                        store_attr.push(line[1].to_i) #price
                    end

                    store = Store.new(store_x, store_y, store_name, *store_attr)
                    gmap.assign(store_x, store_y, store)
                    stores.push(store)
                end
            rescue Exception => e
                puts e.message
                puts "Please input a filename (with its extension)\n\n"
                exit
            end
        end
    else
        if(rest_args.length == 3)
            #Create map with its size and user position defined by user
            n = rest_args[0].to_i
            user_x, user_y = rest_args[1].to_i, rest_args[2].to_i
        else
            #Create map with default option
            n = 20
            user_x, user_y = rand(20), rand(20)
        end

        gmap = Map.new(n)
        user = User.new(user_x, user_y)
        gmap.assign(user_x, user_y, user)

        #Create 5 drivers and 3 stores
        for i in (0...5)
            driver_x, driver_y = rand(0...n), rand(0...n)
            while(!gmap.is_nil(driver_x, driver_y))
                driver_x, driver_y = rand(0...n), rand(0...n)
            end
            driver = Driver.new(driver_x, driver_y)
            gmap.assign(driver_x, driver_y, driver)
             
            drivers.push(driver)
        end

        for i in (0...3)
            store_x, store_y = rand(0...n), rand(0...n)
            while(!gmap.is_nil(store_y, store_y))
                store_x, store_y = rand(0...n), rand(0...n)
            end

            store_attr = random_store(5)
            store_name, *store_attr = store_attr

            store = Store.new(store_x, store_y, store_name, *store_attr)
            gmap.assign(store_x, store_y, store)
            stores.push(store)
        end
    end

    #Loop the game
    while(true)
        puts "Command available:"
        puts "1. Show Map"
        puts "2. Order Food"
        puts "3. View History"
        puts "4. Clear History"
        puts "5. Exit"
        puts ""
        print "Your Command: "
        cmd = STDIN.gets.chomp
        if(cmd.to_i.eql?(1)) || (cmd.eql?("Show Map"))
            for i in (0...n)
                for j in (0...n)
                    gmap.cell[i][j].render
                    print " "
                end
                puts "\n"
            end
            puts "\n"
        elsif(cmd.to_i.eql?(2)) || (cmd.eql?("Order Food"))
            i = 1
            stores.each do |obj|
                puts "#{i}. #{obj.name}"
                i += 1
            end
            puts "\n0. Cancel\n\n"
            puts "You can choose a store by number"
            print "Your Choice: "
            cmd = STDIN.gets.chomp
            if(cmd.to_i.eql?(0)) ||(cmd.eql?("Cancel"))
                puts "Loading the main menu...\n\n"
            elsif(cmd.to_i <= stores.length) && (cmd.to_i > 0)
                selected_store = stores[cmd.to_i - 1]
                done = false
                close = false
                order = Array.new
                while(!done) && (!close)
                    selected_store.show_menu
                    puts "0. Cancel\n\n"
                    puts "You can choose a menu by number"
                    print "Your Choice: "
                    cmd = STDIN.gets.chomp
                    if(cmd.to_i.eql?(0)) ||(cmd.eql?("Cancel"))
                        close = true
                        puts "Loading the main menu...\n\n"
                    elsif(cmd.to_i <= selected_store.num_of_foods) && (cmd.to_i > 0)
                        idx = cmd.to_i - 1
                        order.push(selected_store.foods[idx])
                        order.push(selected_store.prices[idx])
                        puts "\nHow many #{selected_store.foods[idx]} you want to buy?"
                        print "Your Choice: "
                        cmd = STDIN.gets.chomp
                        if(cmd.to_i.eql?(0)) ||(cmd.eql?("Cancel"))
                            close = true
                            puts "Loading the main menu...\n\n"
                        elsif(cmd.to_i > 0)
                            order.push(cmd.to_i)
                            puts "#{cmd.to_i} #{selected_store.foods[idx]} has been added to your order\n\n"
                            puts "Finish the order? (Y/N)"
                            print "Your Choice: "
                            cmd = STDIN.gets.chomp
                            if(cmd.eql?("Y"))
                                done = true
                            end
                        else
                            close = true
                            puts "Wrong input! Getting back to main menu...\n\n"
                        end
                    else
                        close = true
                        puts "Wrong input! Getting back to main menu...\n\n"
                    end
                end
                if(!close)
                    puts "\nYour order: "
                    i = 0
                    total_price = 0
                    while i < order.length
                        puts "#{order[i]} @ #{order[i+1]} x #{order[i+2]}"
                        total_price = total_price + (order[i+1] * order[i+2])
                        i += 3
                    end
                    puts "Total price: #{total_price}\n\n"
                end
            else
                puts "Wrong input! Getting back to main menu...\n\n"
            end
        elsif(cmd.to_i.eql?(3)) || (cmd.eql?("View History"))

        elsif(cmd.to_i.eql?(4)) || (cmd.eql?("Clear History"))
            File.truncate(history, 0)
        elsif(cmd.to_i.eql?(5)) || (cmd.eql?("Exit"))
            puts "Closing the application...\n\n"
            exit
        elsif(cmd.eql?("help"))
            show_help
        else
            puts "Unknown command! Use 'help' to show help\n\n"
        end
    end

end

def execute_arg(args)
    ## Validate the arguments and execute
    if args.length == 0
        execute_game("num")
    elsif args.length == 3
        begin 
            if(Integer(args[0]) < 3)
                puts "Arguments invalid! Map with size #{x}*#{x} is too small\n\n"
                exit
            end
            args.each do |x|
                if(Integer(x) < 0)
                    puts "Arguments invalid! Please input non-negative integer arguments\n\n"
                    exit
                end
            end
        rescue Exception => e
            puts "Arguments invalid! Please input non-negative integer arguments\n\n"
            exit
        end
        execute_game("num", *args)
    elsif args.length == 1
        execute_game("file", *args)
    else
        puts "Arguments invalid! Wrong number of arguments\n\n"
        exit
    end
end

### Main Program
execute_arg(ARGV)