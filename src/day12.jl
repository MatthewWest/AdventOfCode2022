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

function neighbors(map, pos::CartesianIndex)
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
        for n ∈ neighbors(map, p)
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
    # length(a_star(map, manhattan_dist, start, dest)) - 1
    bfs(map, start, (_, p) -> p == dest; get_neighbors=neighbors) - 1
end

iszero(map::Array{Int, 2}, p::CartesianIndex) = map[p] == 0

function neighbors_down(map, p::CartesianIndex)
    steps = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    ns = CartesianIndex[]
    for step ∈ steps
        cand = CartesianIndex(Tuple(p) .+ step)
        if checkbounds(Bool, map, cand) && map[p] - map[cand] <= 1
            push!(ns, cand)
        end
    end
    ns
end

function path_length(p::CartesianIndex, came_from)
    n = 0
    while p !== nothing
        p = get(came_from, p, nothing)
        n += 1
    end
    n
end

function bfs(map, start::CartesianIndex, end_cond::Function; get_neighbors=neighbors_down)
    q = Queue{CartesianIndex}()
    visited = Set{CartesianIndex}()
    from = Dict{CartesianIndex, CartesianIndex}()
    
    push!(visited, start)
    enqueue!(q, start)
    while !isempty(q)
        p = dequeue!(q)
        if end_cond(map, p)
            return path_length(p, from)
        end
        for n ∈ get_neighbors(map, p)
            if n ∉ visited
                push!(visited, n)
                from[n] = p
                enqueue!(q, n)
            end
        end
    end
    return nothing
end

function part2(input = read(INPUT_PATH, String))
    map, _, dest = parse_input(strip(input))
    # BFS returns the path inclusive of the start and end square.
    # We're finding the number of steps.
    bfs(map, dest, iszero) - 1
end

end # module Day12