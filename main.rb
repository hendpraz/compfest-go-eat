### Global Variables
$foods = []
$prices = []
$name = []

### Classes
class Obstacle
    attr_accessor : pos_x
    attr_accessor : pos_x

    def initialize(x, y)
        @pos_x = x
        @pos_y = y
    end
end

class Person < Obstacle
    attr_accessor :name
    def initialize(name)
        @name = name
    end
end

class Store < Obstacle
    attr_accessor :name
    def initialize
        @name = "Warung #{$name[rand($name.length)]}"
        #Create random menu
        @foods = []
        @prices = []
        @num_of_foods = 0
    end

    def show_menu
        puts "Please select your order by number"
        for i in 0...@num_of_foods
            puts "1. #{@foods[i]}  Rp.#{@prices[i]}"
        puts ""
    end
end

class Driver < Person
    attr_accessor :rating
    def initialize
        @rating = 0.0
    end
end

class User < Person
    attr_reader :x
    attr_reader :y
    def initialize(x, y)
        @pos_x = x
        @pos_y = y
    end
end

### Functions
def execute_game(first_arg, *rest_args)
    ##Execute the Go-Eat game

    #Check the first argument is a file or not
    if(first_arg.eql?("file"))
        if(File.exists?(first_arg))
            input_file = File.open(first_arg,"r")
        else
            puts "File not found!"
            exit
        end
    else
        if(rest_args.length == 2)
            n = first_arg
            user_x, user_y = rest_args[0], rest_args[1]
            if(user_x < 0) || (user_y < 0)
                puts "Error, Wrong coordinate of user!"
                exit
        else
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
        execute_game("num",args[0], args[1], args[2])
    elsif args.length == 1
        execute_game("file",args[0])
    else
        puts "Arguments invalid!"
        exit
    end
end

### Main Program
create_database("menu.txt", "name.txt", "history.txt")
execute_arg(ARGV)

#split(/\s*-\s*/)