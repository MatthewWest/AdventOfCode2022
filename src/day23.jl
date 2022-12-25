module Day23

INPUT_PATH = joinpath(@__DIR__, "../data/day23.txt")

function parse_input(s)
    elves = Set{CartesianIndex{2}}()
    for (row, line) ∈ enumerate(split(rstrip(s), "\n"))
        for (col, c) ∈ enumerate(line)
            if c == '#'
                push!(elves, CartesianIndex(col, row))
            end
        end
    end
    elves
end

function adjacents(coord)
    I1 = oneunit(coord)
    filter(c -> c != coord, (coord - I1):(coord + I1))
end

function include_diagonal(δ)
    onex = CartesianIndex(1, 0)
    oney = CartesianIndex(0, 1)
    if δ[1] == 0
        (δ - onex):(δ + onex)
    elseif δ[2] == 0
        (δ - oney):(δ + oney)
    end
end

function propose(elves, coord, moves)
    if all(c -> c ∉ elves, adjacents(coord))
        return coord => coord
    end

    for move ∈ moves
        if all(c -> c ∉ elves, coord .+ include_diagonal(move))
            return coord => coord + move
        end
    end
    return coord => coord
end

const initial_moves = [
    CartesianIndex(0, -1),
    CartesianIndex(0, 1),
    CartesianIndex(-1, 0),
    CartesianIndex(1, 0),
]
function round(elves, round_number)
    i = mod1(round_number, length(initial_moves))
    moves = vcat(initial_moves[i:end], initial_moves[1:i-1])
    proposals = Dict{CartesianIndex{2}, CartesianIndex{2}}()
    for elf ∈ elves
        proposal = propose(elves, elf, moves)
        push!(proposals, proposal)
    end

    counts = Dict{CartesianIndex{2}, Int}()
    for (_, to) ∈ proposals
        counts[to] = get(counts, to, 0) + 1
    end

    next_elves = Set{CartesianIndex{2}}()
    for (from, to) ∈ proposals
        if counts[to] > 1
            push!(next_elves, from)
        else
            push!(next_elves, to)
        end
    end
    next_elves
end

function bounding_rectangle_indices(elves)
    elves_list = collect(elves)
    xs, ys = map(I -> I[1], elves_list), map(I -> I[2], elves_list)
    CartesianIndices((minimum(xs):maximum(xs), minimum(ys):maximum(ys)))
end

function Base.show(io::IO, elves::Set{CartesianIndex{2}})
    bounding_indices = bounding_rectangle_indices(elves)
    minx, maxx = first(bounding_indices)[1], last(bounding_indices)[1]
    miny, maxy = first(bounding_indices)[2], last(bounding_indices)[2]
    print(io, "\n")
    for y ∈ miny:maxy
        for x ∈ minx:maxx
            if CartesianIndex(x, y) ∈ elves
                print(io, "#")
            else
                print(io, ".")
            end
        end
        print(io, "\n")
    end
    print(io, "\n")
end

function part1(input = read(INPUT_PATH, String))
    elves = parse_input(input)
    for i ∈ 1:10
        elves = round(elves, i)
    end
    length(bounding_rectangle_indices(elves)) - length(elves)
end

function part2(input = read(INPUT_PATH, String))
    elves = parse_input(input)
    i = 1
    while true
        new = round(elves, i)
        if new == elves
            return i
        end
        elves = new
        i += 1
    end
end

end # module Day23