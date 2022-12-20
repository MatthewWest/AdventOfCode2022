module Day17

using IterTools

INPUT_PATH = joinpath(@__DIR__, "../data/day17.txt")

@enum Direction LEFT RIGHT

mutable struct Moves{T}
    moves::Vector{T}
    i::Int
end

function parse_input(s)
    Moves([c for c ∈ rstrip(s)], 1)
end

struct Shape
    coords::Array{Tuple{Int, Int}}
end

shapes = [
    # ####
    Shape([(1, 1), (2, 1), (3, 1), (4, 1)]),
    # .#.
    # ###
    # .#.
    Shape([(1, 2), (2, 1), (2, 2), (2, 3), (3, 2)]),
    # ..#
    # ..#
    # ###
    Shape([(1, 1), (2, 1), (3, 1), (3, 2), (3, 3)]),
    # #
    # #
    # #
    # #
    Shape([(1, 1), (1, 2), (1, 3), (1, 4)]),
    # ##
    # ##
    Shape([(1, 1), (1, 2), (2, 1), (2, 2)])
]

mutable struct Rock
    shape::Shape
    minx::Int
    miny::Int
end

mutable struct Grid
    rock_coords::Set{Tuple{Int, Int}}
    maxy::Int
end


function move!(rock, grid, Δ)
    offset = (rock.minx-1, rock.miny-1) .+ Δ
    new_coords = [c .+ offset for c ∈ rock.shape.coords]
    xs, ys = (c[1] for c ∈ new_coords), (c[2] for c ∈ new_coords)
    if (isempty(intersect(grid.rock_coords, new_coords))
        && minimum(ys) >= 1
        && all(x -> x ∈ 1:7, xs))
        rock.minx, rock.miny = offset .+ 1
        return true
    end
    return false
end

function next(moves::Moves{<:Any})
    i = moves.i
    moves.i = (moves.i) % length(moves.moves) + 1
    moves.moves[i]
end

function settle_new_rock(moves::Moves{Char}, grid::Grid, shape::Shape)
    new_rock = Rock(shape, 3, grid.maxy + 4)
    moved_down = true
    while moved_down
        move = next(moves)
        if move == '<'
            Δ = (-1, 0)
        elseif move == '>'
            Δ = (1, 0)
        else
            @error("Unexpected character")
        end
        # attempts to move
        move!(new_rock, grid, Δ)
        moved_down = move!(new_rock, grid, (0, -1))
    end
    new_rock
end

function add_settled_rock!(grid::Grid, rock::Rock)
    offset = (rock.minx - 1, rock.miny - 1)
    absolute_coords = [c .+ offset for c ∈ rock.shape.coords]
    union!(grid.rock_coords, absolute_coords)
    maxy = maximum(c[2] for c ∈ absolute_coords)
    if maxy > grid.maxy
        grid.maxy = maxy
    end
end

function Base.show(io::IO, grid::Grid)
    print(io, '\n')
    for y ∈ (grid.maxy + 4):-1:0
        for x ∈ 0:8
            if y == 0
                if x == 0 || x == 8
                    print(io, '+')
                else
                    print(io, '-')
                end
            elseif x == 0 || x == 8
                print(io, '|')
            else
                if (x, y) ∈ grid.rock_coords
                    print(io, '#')
                else
                    print(io, ' ')
                end
            end
        end
        print(io, '\n')
    end
end

function part1(input = read(INPUT_PATH, String); rocks=2022)
    moves = parse_input(input)
    grid = Grid(Set{Tuple{Int, Int}}(), 0)
    for i ∈ 1:rocks
        rock = settle_new_rock(moves, grid, shapes[((i-1) % 5) + 1])
        add_settled_rock!(grid, rock)
    end
    grid.maxy
end

end # module Day17