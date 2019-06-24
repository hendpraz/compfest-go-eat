### Global Variables
$foods = []
$prices = []
$name = []
$history = nil

### Classes
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
    attr_accessor :name
    attr_accessor :foods
    attr_accessor :prices
    def initialize(name, x, y, *menu)
        super(x, y)
        #"Warung #{$name[rand($name.length)]}"
        @name = name
        @num_of_foods = menu.length

        i = 0
        while i < @num_of_foods
            @foods[i] = menu[i]
            @prices[i] = menu[i + 1]
            i = i + 2
        end
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
end

class User < Person
    attr_reader :x
    attr_reader :y
    def initialize(x, y)
        super("User")
        @pos_x = x
        @pos_y = y
    end
end

### Functions
def create_database(menu, name, history)

end

def execute_game(first_arg, *rest_args)
    ##Execute the Go-Eat game

    if(first_arg.eql?("file"))
        #Create map from file
        if(File.exists?(first_arg))
            input_file = File.open(first_arg,"r")
        else
            puts "File not found!\n"
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
        if (args[0] < 0) || (args[1] < 0) || (args[2] < 0)
            puts "Arguments invalid! Please input non-negative integer arguments\n"
        else
            execute_game("num",args[0], args[1], args[2])
        end
    elsif args.length == 1
        execute_game("file",args[0])
    else
        puts "Arguments invalid! Please input filename in arguments (with its extension)\n"
        exit
    end
end

### Main Program
create_database("menu.txt", "name.txt", "history.txt")
execute_arg(ARGV)

#split(/\s*-\s*/)