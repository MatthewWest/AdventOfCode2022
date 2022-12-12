module Day12

using DataStructures

INPUT_PATH = joinpath(@__DIR__, "../data/day12.txt")

function parse_input(s)
    lines = split(s, "\n")
    rows, cols = length(lines), length(lines[1])
    A = zeros(Int, rows, cols)
    start = nothing
    dest = nothing
    for (row, line) ∈ enumerate(lines)
        for (col, c) ∈ enumerate(line)
            if c == 'S'
                start = CartesianIndex(row, col)
                c = 'a'
            elseif c == 'E'
                dest = CartesianIndex(row, col)
                c = 'z'
            end
            A[row, col] = c - 'a'
        end
    end
    A, start, dest
end

function manhattan_dist(a::CartesianIndex, b::CartesianIndex)::Int
    abs(a[1] - b[1]) + abs(a[2] - b[2])
end

function neighbors(pos::CartesianIndex, map)
    steps = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    ns = CartesianIndex[]
    for step ∈ steps
        cand::CartesianIndex = CartesianIndex(Tuple(pos) .+ step)
        if checkbounds(Bool, map, cand) && (map[cand] - map[pos]) <= 1
            push!(ns, cand)
        end
    end
    ns
end

function construct_path(p::CartesianIndex, came_from::Dict{CartesianIndex, CartesianIndex})
    path = CartesianIndex[]
    while p !== nothing
        pushfirst!(path, p)
        p = get(came_from, p, nothing)
    end
    path
end

function a_star(map, h, start::CartesianIndex, dest::CartesianIndex)
    pq = PriorityQueue{CartesianIndex, Number}()
    cheapest = Dict{CartesianIndex, Int}()
    came_from = Dict{CartesianIndex, CartesianIndex}()

    enqueue!(pq, start, h(start, dest))
    cheapest[start] = 0
    while !isempty(pq)
        p = dequeue!(pq)
        if p == dest
            return construct_path(p, came_from)
        end
        for n ∈ neighbors(p, map)
            cost = cheapest[p] + 1
            if n ∉ keys(cheapest) || cost < cheapest[n]
                cheapest[n] = cost
                came_from[n] = p
                pq[n] = cost + h(n, dest)
            end
        end
    end
    return nothing
end

function part1(input = read(INPUT_PATH, String))
    map, start, dest = parse_input(strip(input))
    path = a_star(map, manhattan_dist, start, dest)
    length(path) - 1
end

function part2(input = read(INPUT_PATH, String))
    map, _, dest = parse_input(strip(input))
    min_length = typemax(Int)
    for a_pos ∈ findall(iszero, map)
        path = a_star(map, manhattan_dist, a_pos, dest)
        if path === nothing
            continue
        end
        l = length(path) - 1
        if l < min_length
            min_length = l
        end
    end
    min_length
end

end # module Day12