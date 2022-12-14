module Day14

INPUT_PATH = joinpath(@__DIR__, "../data/day14.txt")

@enum Square AIR ROCK SAND

mutable struct Cave
    map::Dict{Tuple{Int, Int}, Square}
    minx::Int
    maxx::Int
    maxy::Int
end

function new_cave()
    Cave(Dict{Tuple{Int, Int}, Square}(), typemax(Int), typemin(Int), typemin(Int))
end

function set_square!(cave, coord, value)
    x, y = coord
    if x < cave.minx
        cave.minx = x
    end
    if x > cave.maxx
        cave.maxx = x
    end
    if y > cave.maxy
        cave.maxy = y
    end
    cave.map[coord] = value
end

function draw_path!(cave, a, b)
    x1, y1 = a
    x2, y2 = b
    dx, dy = sign(x2-x1), sign(y2-y1)
    x, y = x1, y1
    while x != x2 || y != y2
        set_square!(cave, (x, y), ROCK)
        x += dx
        y += dy
    end
    set_square!(cave, (x, y), ROCK)
end

function parse_input(s)
    lines = split(rstrip(s), "\n")
    cave = new_cave()
    for line ∈ lines
        points = Vector{Tuple{Int, Int}}()
        for point ∈ split(line, "->")
            x, y = split(point, ",")
            push!(points, (parse(Int, x), parse(Int, y)))
        end
        for i ∈ 1:(length(points)-1)
            draw_path!(cave, points[i], points[i+1])
        end
    end
    cave
end

function print_cave(cave)
    for y ∈ 0:cave.maxy
        for x ∈ cave.minx:cave.maxx
            c = get(cave.map, (x, y), AIR)
            if c == AIR
                print('.')
            elseif c == ROCK
                print('#')
            elseif c == SAND
                print('o')
            end
        end
        print("\n")
    end
end

function settle(cave, pos)
    # if we'd fall past the last rock, we'll never settle so return nothing.
    if pos[2] > cave.maxy
        return nothing
    end
    # prefer straight down, then left diagonal, then right diagonal
    for δ ∈ [(0, 1), (-1, 1), (1, 1)]
        cand = pos .+ δ
        if get(cave.map, cand, AIR) == AIR
            return cand
        end
    end
    return pos
end

# returns true when sand is falling to the abyss
function settle_sand!(cave, origin)
    pos = nothing
    new_pos = origin
    while pos != new_pos
        pos = new_pos
        new_pos = settle(cave, pos)
        # part 1 end condition: the sand falls into the abyss
        if new_pos === nothing
            return true
        end
    end
    set_square!(cave, new_pos, SAND)
    # part 2 end condition: sand fills to the origin
    if new_pos == origin
        return true
    end
    return false
end

function part1(input = read(INPUT_PATH, String); print=false)
    cave = parse_input(input)
    done = false
    while !done
        done = settle_sand!(cave, (500, 0))
    end
    print && print_cave(cave)
    count(s -> s == SAND, collect(values(cave.map)))
end

function part2(input = read(INPUT_PATH, String); print=false)
    cave = parse_input(input)
    # draw a floor 2 below the lowest rock, and far enough out in x that sand can't possibly overflow
    floor_y = cave.maxy + 2
    draw_path!(cave, (cave.minx - cave.maxy, floor_y), (cave.maxx + cave.maxy, floor_y))
    done = false
    while !done
        done = settle_sand!(cave, (500, 0))
    end
    print && print_cave(cave)
    count(s -> s == SAND, collect(values(cave.map)))
end

end # module Day14
