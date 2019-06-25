### Global Variables
$foods = []
$prices = []
$name = []
$history = []

### Classes
class Map
    attr_reader :size
    def initialize(size)
        @size = size
    end
end

class Cell
    attr_accessor :obstacle
    
    def initialize
        @obstacle = nil
    end

    def render()
        print "-"
    end
end

class Obstacle
    attr_accessor :pos_x
    attr_accessor :pos_y

    def initialize(x, y)
        @pos_x = x
        @pos_y = y
    end
end

class Person < Obstacle
    attr_accessor :name
    def initialize(name, x, y)
        super(x, y)
        @name = name
    end
end

class Store < Obstacle
    attr_accessor :name , :foods, :prices
    def initialize(name, x, y, *menu)
        super(x, y)
        #"Warung #{$name[rand($name.length)]}"
        @name = name
        @num_of_foods = menu.length / 2

        i = 0
        while i < menu.length
            @foods[i] = menu[i]
            @prices[i] = menu[i + 1]
            i = i + 2
        end
    end

    def render
        print "S"
    end

    def show_menu
        puts "Please select your order by number"
        for i in 0...@num_of_foods
            puts "1. #{@foods[i]}  Rp.#{@prices[i]}"
        end
        puts ""
    end
end

class Driver < Person
    attr_accessor :rating
    def initialize
        super($name[rand($name.length)])
        @rating = 0.0
    end

    def render
        print "D"
    end
end

class User < Person
    attr_reader :x
    attr_reader :y
    def initialize(x, y)
        super("User")
        @pos_x = x
        @pos_y = y
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
                $prices.push(temp[1])
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

def execute_game(first_arg, *rest_args)
    ##Execute the Go-Eat game
    create_database("menu.txt", "name.txt", "history.txt")

    if(first_arg.eql?("file"))
        #Create map from file
        begin
            input_file = File.open(rest_args[0],"r")
        rescue Exception => e
            puts e.message
            puts "Please input a filename (with its extension)\n\n"
            exit
        end
    else
        if(rest_args.length == 2)
            #Create map with its size and user position defined by user
            n = first_arg
            user_x, user_y = rest_args[0], rest_args[1]
        else
            #Create map with default option
            n = 20
            user_x, user_y = rand(21), rand(21)
        end

    end

end

def execute_arg(args)
    ## Validate the arguments and execute
    if args.length == 0
        execute_game("num")
    elsif args.length == 3
        args.each do |x|
            begin 
                if(Integer(x) < 0)
                    puts "Arguments invalid! Please input non-negative integer arguments\n\n"
                    exit
                end
            rescue Exception => e
                puts "Arguments invalid! Please input integer arguments\n\n"
                exit
            end
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