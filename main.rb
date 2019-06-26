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

    def assign(obj)
        #assign object to map cell
        x = obj.x
        y = obj.y
        @cell[x][y].creation = obj
        @cell[x][y].is_nil = false
    end

    def delete_driver(x, y)
        @cell[x][y].creation = nil
        @cell[x][y].is_nil = true
    end

    def is_nil(x, y)
        #check wether cell in [x,y] nil or not
        temp = @cell[x][y]
        temp.is_nil
    end
end

class Cell
    attr_accessor :creation, :is_nil

    def initialize
        @creation = nil
        @is_nil = true
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
            @foods.push(menu[i])
            @prices.push(menu[i + 1])
            @num_of_foods += 1
            i = i + 2
        end
    end

    def render
        print "S"
    end

    def show_menu
        puts "\nPlease select your order by number"
        for i in 0...@num_of_foods
            puts "#{i+1}. #{@foods[i]}  Rp.#{@prices[i]}"
        end
        puts ""
    end
end

class Driver < Person
    attr_accessor :rating, :num_of_rate, :sum_of_rates
    def initialize(x, y)
        super(x, y, $name[rand($name.length)])
        @rating = 0.0
        @num_of_rate = 0
        @sum_of_rates = 0
    end

    def rate(user_rate)
        @num_of_rate += 1
        @sum_of_rates = @sum_of_rates + user_rate
        @rating = @sum_of_rates.to_f / @num_of_rate
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
                $history.push(line.strip) #name
                
                num_of_foods = str.gets.to_i
                for i in (1..num_of_foods+1)
                    #Add each order and total price
                    line = str.gets.chomp
                    $history.push(line)
                end

                while line != "---"
                    line = str.gets.chomp #Skip driver's name and routes
                end
                $history.push(line) #Add '---'
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

def random_driver(gmap)
    n = gmap.size
    
    temp = random_coordinate(gmap)
    driver_x, driver_y = temp[0], temp[1]
    
    driver = Driver.new(driver_x, driver_y)

    driver
end

def show_help
    puts "Please select a command by inputing a number"
    puts "For example, your command: 1\n\n"
end

def view_history
    if $history.length == 0
        puts "\nNothing on your history...\n\n"
    else
        puts "\nOrder History:\n\n"
        $history.each do |line|
            puts line.strip
        end
        puts ""
    end
end

def manhattan(x1, y1, x2, y2)
    score = (x1 - x2).abs + (y1 - y2).abs

    score
end

def closest_point(x1, y1, x2, y2)
    temp = Array.new
    curr_manhattan = manhattan(x1, y1, x2, y2)
    if (manhattan(x1, y1 + 1, x2, y2)) < curr_manhattan
        temp.push(x1)
        temp.push(y1 + 1)
    elsif (manhattan(x1, y1 - 1, x2, y2)) < curr_manhattan
        temp.push(x1)
        temp.push(y1 - 1)
    elsif (manhattan(x1 + 1, y1, x2, y2)) < curr_manhattan
        temp.push(x1 + 1)
        temp.push(y1)
    elsif (manhattan(x1 - 1, y1, x2, y2)) < curr_manhattan
        temp.push(x1 - 1)
        temp.push(y1)
    end

    temp
end

def check_validity(n, num)
    if(n < 2) || (n**2 < num)
        puts "Map size are too small"
        exit
    end
end

def is_in_map(x, y, n)
    in_map = true
    if(x < 0) || (y < 0) || (x >= n) || (y >= n)
        in_map = false
    end

    in_map
end

def random_coordinate(gmap)
    coor = Array.new
    count_of_rand = 0
    while (count_of_rand <= 3)
        coor.push(rand(0...gmap.size))
        coor.push(rand(0...gmap.size))
        if(!gmap.is_nil(coor[0], coor[1]))
            coor = Array.new
        end
        count_of_rand += 1
    end
    
    if(count_of_rand > 3)
        n = gmap.size
        for i in (0...n)
            for j in (0...n)
                if(gmap.is_nil(i,j))
                    coor.push(i)
                    coor.push(j)
                    break
                end
            end
        end
    end
    coor
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
        begin
            File.open(rest_args[0],"r") do |str|
                #Create Map
                line = str.gets
                n = line.to_i
                num_of_creation = 0
                check_validity(n, num_of_creation)
                gmap = Map.new(n)
            
                #Create User
                line = str.gets.split(" ")
                num_of_creation += 1
                user_x = line[0].to_i 
                user_y = line[0].to_i
                if is_in_map(user_x, user_y, n)
                    user = User.new(user_x,user_y)
                    gmap.assign(user)
                else
                    puts "Wrong coordinate of user!\n"
                    exit
                end
                
                p = str.gets.to_i #number of drivers
                num_of_creation += p
                check_validity(n, num_of_creation)
                for i in (0...p)
                    line = str.gets.split(" ")
                    driver_x = line[0].to_i
                    driver_y = line[1].to_i
                    if is_in_map(driver_x, driver_y, n)
                        driver = Driver.new(driver_x, driver_y)
                        gmap.assign(driver)
                        drivers.push(driver)
                    else
                        puts "Wrong coordinate of a driver!\n"
                        exit
                    end
                end

                q = str.gets.to_i #number of store
                num_of_creation += q
                check_validity(n, num_of_creation)
                for i in (0...q)
                    line = str.gets.split(" ")
                    store_x = line[0].to_i
                    store_y = line[1].to_i
                    if is_in_map(store_x,store_y, n)
                        store_attr = []
                        store_name = str.gets.chomp #Store name
                        r = str.gets.to_i #Store menu
                        for j in (0...r)
                            line = str.gets.split(/\s*@\s*/)
                            store_attr.push(line[0].strip) #food
                            store_attr.push(line[1].to_i) #price
                        end
                    else
                        puts "Wrong coordinate of a store!\n"
                        exit
                    end

                    store = Store.new(store_x, store_y, store_name, *store_attr)
                    gmap.assign(store)
                    stores.push(store)
                end
            end
        rescue Exception => e
            puts e.message
            puts "Please input a filename (with its extension)\n\n"
            exit
        end
        
    else
        if(rest_args.length == 3)
            #Create map with its size and user position defined by user
            n = rest_args[0].to_i
            user_x, user_y = rest_args[1].to_i, rest_args[2].to_i
            if !(is_in_map(user_x, user_y, n))
                puts "Wrong user coordinate"
                exit
            end
        else
            #Create map with default option
            n = 20
            user_x, user_y = rand(20), rand(20)
        end

        gmap = Map.new(n)
        user = User.new(user_x, user_y)
        gmap.assign(user)

        #Create 5 drivers and 3 stores
        for i in (1..5)
            driver = random_driver(gmap)
            gmap.assign(driver)
             
            drivers.push(driver)
        end

        for i in (1..3)
            temp = random_coordinate(gmap)
            store_x, store_y = temp[0], temp[1]

            store_attr = random_store(5)
            store_name, *store_attr = store_attr

            store = Store.new(store_x, store_y, store_name, *store_attr)
            gmap.assign(store)
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
            selected_store = nil
            i = 1
            stores.each do |obj|
                puts "#{i}. #{obj.name} at (#{obj.x},#{obj.y})"
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
                            if(cmd.eql?("Y")) || (cmd.eql?("Yes")) || (cmd.eql?("y"))
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
                    order_history = Array.new
                    #Write store name to file
                    $history.push(selected_store.name)
                    order_history.push(selected_store.name)
                    #Write order selected = order array length / 3
                    order_history.push(order.length / 3)
                    
                    puts "\nYour order: "
                    i = 0
                    total_price = 0
                    while i < order.length
                        #Write each order
                        temp = "#{order[i]} @ #{order[i+1]} x #{order[i+2]}"
                        order_history.push(temp)
                        $history.push(temp)
                        puts temp

                        total_price = total_price + (order[i+1] * order[i+2])
                        i += 3
                    end

                    #Find the closest Go-Eat driver
                    min = gmap.size ** 2
                    selected_driver = nil
                    driver_idx = -1
                    idx = 0
                    drivers.each do |obj|
                        temp = manhattan(obj.x, obj.y, selected_store.x, selected_store.y)
                        if temp < min
                            selected_driver = obj
                            min = temp
                            driver_idx = idx
                        end
                        idx += 1
                    end

                    #Add the delivery fee
                    unit_costs = 300
                    distance = min + manhattan(user.x, user.y, selected_store.x, selected_store.y)
                    total_price = total_price + (unit_costs * distance)
                    puts "Total price with delivery fee: #{total_price}\n\n"
                    order_history.push(total_price)

                    #Write selected driver name
                    order_history.push(selected_driver.name)
                    #Write routes
                    curr_x, curr_y = selected_driver.x, selected_driver.y
                    str = "driver is on the way to store, start at (#{curr_x},#{curr_y})"
                    puts str
                    order_history.push(str)
                    
                    distance = manhattan(curr_x, curr_y, selected_store.x, selected_store.y)
                    while distance != 0
                        temp = closest_point(curr_x, curr_y, selected_store.x, selected_store.y)
                        curr_x, curr_y = temp[0], temp[1]
                        
                        str = "go to (#{curr_x},#{curr_y})"
                        distance = manhattan(curr_x, curr_y, selected_store.x, selected_store.y)
                        if distance == 0
                            str = str + ", driver arrived at the store!"
                        end
                        puts str
                        order_history.push(str)
                    end

                    str = "driver has bought the item(s), start at (#{curr_x},#{curr_y})"
                    puts str
                    order_history.push(str)

                    distance = manhattan(curr_x, curr_y, user.x, user.y)
                    while distance != 0
                        temp = closest_point(curr_x, curr_y, user.x, user.y)
                        curr_x, curr_y = temp[0], temp[1]
                        
                        str = "go to (#{curr_x},#{curr_y})"
                        distance = manhattan(curr_x, curr_y, user.x, user.y)
                        if distance == 0
                            str = str + ", driver arrived at your place!"
                        end
                        puts str
                        order_history.push(str)
                    end
                    order_history.push('---')
                    puts "\nEnjoy your order!\n\n"
                    puts "Please rate the driver with integer in range 1 to 5 (inclusive)"
                    print "Rating : "
                    cmd = STDIN.gets.chomp
                    while(cmd.to_i < 1) || (cmd.to_i > 5)
                        puts "You should put integer in range 1 to 5 (inclusive)"
                        print "Rating : "
                        cmd = STDIN.gets.chomp
                    end
                    puts ""
                    selected_driver.rate(cmd.to_i)
                    if(selected_driver.rating < 3)
                        #Remove the driver, generate new driver
                        puts "A driver has been removed from the map"
                        puts "Go-Eat is looking for a driver..."
                        drivers.delete_at(driver_idx)
                        gmap.delete_driver(selected_driver.x, selected_driver.y)

                        driver = random_driver(gmap)
                        gmap.assign(driver)
                        
                        drivers.push(driver)
                        puts "A new driver has arrived!\n\n"
                    end

                    File.open(history, 'a') do |file|
                        order_history.each do |line|
                            file.puts "#{line}"
                        end
                    end
                end
            else
                puts "Wrong input! Getting back to main menu...\n\n"
            end
        elsif(cmd.to_i.eql?(3)) || (cmd.eql?("View History"))
            view_history
        elsif(cmd.to_i.eql?(4)) || (cmd.eql?("Clear History"))
            File.truncate(history, 0)
            $history = Array.new
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
                x = args[0]
                puts "Arguments invalid! Map with size #{x}*#{x} is too small\n"
                exit
            end
            args.each do |x|
                if(Integer(x) < 0)
                    puts "Arguments invalid!\n"
                    exit
                end
            end
        rescue Exception => e
            puts "Please input non-negative integer arguments\n"
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