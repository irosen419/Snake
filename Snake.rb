require 'ruby2d'

set background: 'navy'
set fps_cap: 20

SQUARE_SIZE = 20
GRID_WIDTH = Window.width / SQUARE_SIZE
GRID_HEIGHT = Window.height / SQUARE_SIZE

class Snake
    attr_writer :direction

    def initialize
        @positions = [[2, 0], [2, 1], [2, 2], [2, 3]]
        @direction = 'down'
        @growing = false
    end

    def draw
        @positions.each do |position|
            Square.new(x: position[0] * SQUARE_SIZE, y: position[1] * SQUARE_SIZE, size: SQUARE_SIZE - 1, color: 'white')
        end
    end

    def move
        if !@growing
            @positions.shift
        end
       
        case @direction
        when 'down'
            @positions.push(new_coords(head[0], head[1] + 1))
        when 'up'
            @positions.push(new_coords(head[0], head[1] - 1))
        when 'left'
            @positions.push(new_coords(head[0] - 1, head[1]))
        when 'right'
            @positions.push(new_coords(head[0] + 1, head[1]))
        end
        @growing = false
    end

    def can_change_direction_to?(new_direction)
        case @direction
        when 'up' then new_direction != 'down'
        when 'down' then new_direction != 'up'
        when 'left' then new_direction != 'right'
        when 'right' then new_direction != 'left'
        end
    end

    def x
        head[0]
    end

    def y
        head[1]
    end

    def grow
        @growing = true
    end

    def hit_itself?
       @positions.uniq.length != @positions.length
    end

    private

    def new_coords(x, y)
        [x % GRID_WIDTH, y % GRID_HEIGHT]
    end

    def head
        @positions.last
    end

end

class Game
    def initialize
        @score = 0
        @ball_x = rand(GRID_WIDTH)
        @ball_y = rand(GRID_HEIGHT)
        @finished = false
    end

    def draw
        unless finished?
           Square.new(x: @ball_x * SQUARE_SIZE, y: @ball_y * SQUARE_SIZE, size: SQUARE_SIZE, color: 'yellow')
        end
        Text.new(text_message, color: "green", x: 10, y: 10, size: 25)
        Text.new(high_score_text, color: "green", x: 10, y: 40, size: 25)
    end

    def snake_hit_ball?(x, y)
        @ball_x == x && @ball_y == y
    end

    def record_hit
        @score += 1
        @ball_x = rand(Window.width / SQUARE_SIZE)
        @ball_y = rand(Window.height / SQUARE_SIZE)
    end

    def finish
        @finished = true
    end

    def finished?
        @finished
    end

    private

    def high_score
        File.new("./highscore.txt")
    end

    def high_score_writer
        if @score > high_score.read(2).to_i
            IO.write("./highscore.txt", @score)
        end
    end

    def text_message
        if finished?
            high_score_writer
            "Game over. Your score was #{@score}. " 
        else
            "Score: #{@score}"
        end
    end

    def high_score_text
        if finished?
            high_score_writer
            if @score <= high_score.read(2).to_i
                "Current high score: #{high_score.read(2)} Press 'R' to restart. "
            else
                "Congratulations! Your new high score is #{high_score.read(2)} Press 'R' to restart. "
            end
        else
            "High Score: #{high_score.read(2)}"
        end
    end

end

snake = Snake.new
game = Game.new

update do
    clear
    
    unless game.finished?
        snake.move
    end
    snake.draw
    game.draw

    if game.snake_hit_ball?(snake.x, snake.y)
        game.record_hit
        snake.grow
    end

    if snake.hit_itself?
        game.finish
    end
end

on :key_down do |event|
    if ['up', 'down', 'left', 'right'].include?(event.key)
        if snake.can_change_direction_to?(event.key)
            snake.direction = event.key
        end
    end

    if game.finished? && event.key == 'r'
        snake = Snake.new
        game = Game.new
    end
end

show
