module Day22

INPUT_PATH = joinpath(@__DIR__, "../data/day22.txt")

test_input = 
raw"""
        ...#
        .#..
        #...
        ....
...#.......#
........#...
..#....#....
..........#.
        ...#....
        .....#..
        .#......
        ......#.

10R5L5R10L4R5L5
"""

@enum Square WALL OPEN EMPTY
@enum Facing RIGHT DOWN LEFT UP
Map = Dict{Tuple{Int, Int}, Square}

struct Position
    col::Int
    row::Int
    facing::Facing
end

@enum Turn LTURN RTURN

Move = Int

Cmd = Union{Turn, Move}

function parse_square(c)
    if c == '#'
        WALL
    elseif c == '.'
        OPEN
    else
        @error("Found an unexpected character '$c'")
    end
end

function parse_path(path_string)
    cmds = Cmd[]
    parts = Char[]
    for c ∈ path_string
        if isnumeric(c)
            push!(parts, c)
        elseif !isnumeric(c)
            if c == 'L'
                turn = LTURN
            elseif c == 'R'
                turn = RTURN
            else
                @error("Unrecognized non-numeric character $c")
            end
            push!(cmds, parse(Int, join(parts)), turn)
            parts = empty!(parts)
        end
    end
    if !isempty(parts)
        push!(cmds, parse(Int, join(parts)))
    end
    cmds
end
function parse_input(s)
    map_string, path = split(rstrip(s), "\n\n")
    squares = Dict{Tuple{Int, Int}, Square}()
    for (row, line) ∈ enumerate(split(map_string, "\n"))
        for (col, c) ∈ enumerate(line)
            if c != ' '
                squares[(col, row)] = parse_square(c)
            end
        end
    end

    cmds = parse_path(path)
    squares, cmds
end

function Base.show(io::IO, squares::Map)
    coords = keys(squares)
    maxx, maxy = maximum(first.(coords)), maximum(last.(coords))
    for row ∈ 1:maxy
        for col ∈ 1:maxx
            c = get(squares, (col, row), EMPTY)
            if c == EMPTY
                print(io, " ")
            elseif c == OPEN
                print(io, ".")
            elseif c == WALL
                print(io, "#")
            end
        end
        print(io, "\n")
    end
end

const δs = (1, 0), (0, 1), (-1, 0), (0, -1)
get_delta(facing::Facing) = δs[mod1(Int(facing)+1, length(instances(Facing)))]

function turn(facing::Facing, turn::Turn)
    if turn == RTURN
        facing_diff = 1
    else
        facing_diff = -1
    end
    Facing(mod(Int(facing) + facing_diff, length(instances(Facing))))
end

function step(squares::Map, position::Position, command::Cmd)
    if typeof(command) == Int
        δ = get_delta(position.facing)
        pos = position.col, position.row
        for _ ∈ 1:command
            newpos = pos .+ δ
            # Wrapping logic
            if get(squares, newpos, EMPTY) == EMPTY
                tmp = pos
                while true
                    next = tmp .- δ
                    if get(squares, next, EMPTY) == EMPTY
                        newpos = tmp
                        break
                    end
                    tmp = next
                end
            end
            # Check to make sure we wrapped correctly
            @assert get(squares, newpos, EMPTY) != EMPTY "Found EMPTY at $newpos"
            # Check if we're running into a wall and end early
            if squares[newpos] == WALL
                break
            end
            pos = newpos
        end
        return Position(pos[1], pos[2], position.facing)
    elseif typeof(command) == Turn
        return Position(
            position.col,
            position.row, 
            turn(position.facing, command))
    end
end

function start_position(squares::Map)
    coords = collect(keys(squares))
    starty = minimum(last.(coords))
    filter!(p -> p[2] == starty, coords)
    startx = minimum(first.(coords))
    Position(startx, starty, RIGHT)
end

function password(pos::Position)
    pos.row * 1000 + pos.col * 4 + Int(pos.facing)
end

function part1(input = read(INPUT_PATH, String))
    map, cmds = parse_input(input)
    pos = start_position(map)
    positions = [pos]
    for cmd ∈ cmds
        pos = step(map, pos, cmd)
        push!(positions, pos)
    end
    password(last(positions))
end

function parse_side(map_array, origin, side_length)
    side = Array{Square, 2}(undef, (side_length, side_length))
    I1 = oneunit(origin)
    offset = origin - I1
    for I ∈ origin:(offset + CartesianIndex(side_length, side_length))
        side[I - offset] = parse_square(map_array[I])
    end
    return side
end

# Following the numbering from the problem description
@enum FaceAspect F_TOP F_BACK F_LEFT F_FRONT F_BOTTOM F_RIGHT
@enum Edge E_RIGHT E_DOWN E_LEFT E_UP

CubeMap = Vector{Matrix{Square}}

struct CubePosition
    face_pos::CartesianIndex{2}
    face::FaceAspect
    facing::Facing
end

function build_adjacency(side_length)
    adjacency = Dict{Tuple{FaceAspect, Edge}, Tuple{FaceAspect, Edge}}()
    if side_length == 4
        edges = Dict([
            (F_TOP, E_RIGHT) => (F_RIGHT, E_RIGHT),
            (F_TOP, E_DOWN) => (F_FRONT, E_UP),
            (F_TOP, E_LEFT) => (F_LEFT, E_UP),
            (F_TOP, E_UP) => (F_BACK, E_UP),
            (F_BACK, E_RIGHT) => (F_LEFT, E_LEFT),
            (F_BACK, E_DOWN) => (F_BOTTOM, E_DOWN),
            (F_BACK, E_LEFT) => (F_RIGHT, E_DOWN),
            (F_LEFT, E_RIGHT) => (F_FRONT, E_LEFT),
            (F_LEFT, E_DOWN) => (F_BOTTOM, E_LEFT),
            (F_FRONT, E_RIGHT) => (F_RIGHT, E_UP),
            (F_FRONT, E_DOWN) => (F_BOTTOM, E_UP),
            (F_BOTTOM, E_RIGHT) => (F_RIGHT, E_LEFT),
        ])
    elseif side_length == 50
        edges = Dict([
            (F_TOP, E_RIGHT) => (F_RIGHT, E_LEFT),
            (F_TOP, E_DOWN) => (F_FRONT, E_UP),
            (F_TOP, E_LEFT) => (F_LEFT, E_LEFT),
            (F_TOP, E_UP) => (F_BACK, E_LEFT),
            (F_BACK, E_RIGHT) => (F_BOTTOM, E_DOWN),
            (F_BACK, E_DOWN) => (F_RIGHT, E_UP),
            (F_BACK, E_UP) => (F_LEFT, E_DOWN),
            (F_LEFT, E_RIGHT) => (F_BOTTOM, E_LEFT),
            (F_LEFT, E_UP) => (F_FRONT, E_LEFT),
            (F_FRONT, E_RIGHT) => (F_RIGHT, E_DOWN),
            (F_FRONT, E_DOWN) => (F_BOTTOM, E_UP),
            (F_BOTTOM, E_RIGHT) => (F_RIGHT, E_RIGHT),
        ])
    end
    for (e1, e2) ∈ edges
        adjacency[e1] = e2
        adjacency[e2] = e1
    end
    adjacency
end

function get_origins(side_length)
    if side_length == 4
        return [
            CartesianIndex(side_length*2 + 1, 1), # Top
            CartesianIndex(1, side_length+1), # Back
            CartesianIndex(side_length+1, side_length+1), # Left
            CartesianIndex(side_length*2 + 1, side_length+1), # Front
            CartesianIndex(side_length*2 + 1, side_length*2 + 1), # Bottom
            CartesianIndex(side_length*3 + 1, side_length*2 + 1), # Right
        ]
    elseif side_length == 50
        return [
            CartesianIndex(side_length + 1, 1), # Top
            CartesianIndex(1, side_length*3 + 1), # Back
            CartesianIndex(1, side_length*2 + 1), # Left
            CartesianIndex(side_length + 1, side_length + 1), # Front
            CartesianIndex(side_length + 1, side_length*2 + 1), # Bottom
            CartesianIndex(side_length*2 + 1, 1), # Right
        ]
    else
        @error("Unrecognized side length $side_length")
    end
end

function parse_input2(s)
    map_string, path_string = split(rstrip(s), "\n\n")
    map_lines = split(map_string, "\n")
    side_length_float = sqrt(count(c -> !isspace(c), map_string) // 6)
    if isinteger(side_length_float)
        side_length = Int(side_length_float)
    end

    map_array = fill(' ', (maximum(length.(map_lines)), length(map_lines)))
    for (row, line) ∈ enumerate(split(map_string, "\n"))
        for (col, c) ∈ enumerate(line)
            if c != ' '
                map_array[col, row] = c
            end
        end
    end

    origins = get_origins(side_length)
    cube = [parse_side(map_array, origin, side_length) for origin ∈ origins]

    cmds = parse_path(path_string)
    cube, cmds
end

face(cube::CubeMap, face::FaceAspect) = cube[Int(face) + 1]

function edge_reached(facing::Facing)
    if facing == RIGHT
        E_RIGHT
    elseif facing == DOWN
        E_DOWN
    elseif facing == LEFT
        E_LEFT
    else
        E_UP
    end
end

function new_facing(edge::Edge)
    if edge == E_RIGHT
        LEFT
    elseif edge == E_DOWN
        UP
    elseif edge == E_LEFT
        RIGHT
    else
        DOWN
    end
end

get_square(cube::CubeMap, position::CubePosition) = face(cube, position.face)[position.face_pos]

function wrap(position::CubePosition, side_length, adjacency)
    curr_face, curr_edge = position.face, edge_reached(position.facing)
    dest_face, dest_edge = adjacency[(curr_face, curr_edge)]
    edge_diff = mod(Int(dest_edge) - Int(curr_edge), 4)
    # Wrapping to the same edge - the faces have up orientations pointing opposite directions
    if edge_diff == 0
        @assert curr_edge == dest_edge
        # Top and bottom edges keep the same y, invert the x (mirror image)
        if curr_edge == E_DOWN || curr_edge == E_UP
            new_face_pos = CartesianIndex(
                side_length + 1 - position.face_pos[1],
                position.face_pos[2]
            )
        # Left and right edges keep the same x, invert the y
        else
            new_face_pos = CartesianIndex(
                position.face_pos[1],
                side_length + 1 - position.face_pos[2]
            )
        end
    elseif edge_diff == 2 # opposite edges
        # Top and bottom wrapping keeps the same X, inverts Y
        if curr_edge == E_DOWN || curr_edge == E_UP
            new_face_pos = CartesianIndex(
                position.face_pos[1],
                side_length + 1 - position.face_pos[2]
            )
        # Left and right wrapping inverts X, keeps the same Y
        else
            new_face_pos = CartesianIndex(
                side_length + 1 - position.face_pos[1],
                position.face_pos[2]
            )
        end
    else
        pair = [curr_edge, dest_edge]
        if issetequal(pair, [E_RIGHT, E_DOWN]) ||
            issetequal(pair, [E_UP, E_LEFT])
            # Just switch the coordinates
            new_face_pos = CartesianIndex(
                position.face_pos[2],
                position.face_pos[1]
            )
        else
            # switch and invert the coordinates
            new_face_pos = CartesianIndex(
                side_length + 1 - position.face_pos[2],
                side_length + 1 - position.face_pos[2]
            )
        end
    end
    return CubePosition(new_face_pos, dest_face, new_facing(dest_edge))
end

function step(cube::CubeMap, position::CubePosition, command::Cmd, adjacency)
    if typeof(command) == Int
        δ = get_delta(position.facing)
        pos = position
        positions = CubePosition[]
        for _ ∈ 1:command
            newpos = CubePosition(CartesianIndex(Tuple(pos.face_pos) .+ δ), pos.face, pos.facing)
            # Wrapping logic
            if !checkbounds(Bool, face(cube, newpos.face), newpos.face_pos)
                newpos = wrap(pos, size(cube[1], 1), adjacency)
                δ = get_delta(newpos.facing)
            end
            # Check if we're running into a wall and end early
            if get_square(cube, newpos) == WALL
                break
            end
            pos = newpos
            push!(positions, pos)
        end
        return positions
    elseif typeof(command) == Turn
        pos = CubePosition(position.face_pos, position.face, turn(position.facing, command))
        return [pos]
    end
end

function start_cube_position()
    CubePosition(CartesianIndex(1, 1), F_TOP, RIGHT)
end

function facing_2d(pos::CubePosition)
    if pos.face ∈ [F_FRONT, F_TOP, F_LEFT, F_BOTTOM]
        pos.facing
    elseif pos.face == F_BACK
        Facing(mod(Int(pos.facing) + 2, length(instances(Facing))))
    else
        Facing(mod(Int(pos.facing) + 1, length(instances(Facing))))
    end
end

function to2d(pos::CubePosition, side_length)
    origins = get_origins(side_length)
    origin = origins[Int(pos.face) + 1]
    I1 = oneunit(origin)
    offset = origin - I1
    pos2d = offset + pos.face_pos
    facing2d = facing_2d(pos)
    return Position(pos2d[1], pos2d[2], facing2d)
end

function password(pos::CubePosition, side_length)
    password(to2d(pos, side_length))
end

function part2(input = read(INPUT_PATH, String))
    cube, cmds = parse_input2(input)
    adjacency = build_adjacency(size(cube[1], 1))

    pos = start_cube_position()
    positions = [pos]
    for cmd ∈ cmds
        intermediates = step(cube, pos, cmd, adjacency)
        push!(positions, intermediates...)
        pos = if length(intermediates) > 0
            last(intermediates)
        else
            pos
        end
    end
    password(last(positions), size(cube[1], 1))
end

end # module Day22