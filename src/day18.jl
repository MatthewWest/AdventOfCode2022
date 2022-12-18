module Day18
using DataStructures

INPUT_PATH = joinpath(@__DIR__, "../data/day18.txt")

const δs = [(1, 0, 0), (0, 1, 0), (0, 0, 1), (-1, 0, 0), (0, -1, 0), (0, 0, -1)]

function parse_input(s)
    coords = Tuple{Int, Int, Int}[]
    for line ∈ split(rstrip(s), "\n")
        x, y, z = parse.(Int, split(line, ","))
        push!(coords, (x, y, z))
    end
    Set(coords)
end

function open_sides(coords)
    n = 0
    for coord ∈ coords
        for δ ∈ δs
            if coord .+ δ ∉ coords
                n += 1
            end
        end
    end
    n
end

function part1(input = read(INPUT_PATH, String))
    coords = parse_input(input)
    open_sides(coords)
end

function inbounds(coord, mins, maxes)
    all(coord[i] >= mins[i] && coord[i] <= maxes[i] for i ∈ 1:3)
end

function atbounds(coord, mins, maxes)
    any(coord[i] <= mins[i] || coord[i] >= maxes[i] for i ∈ 1:3)
end


function flood_fill(coords, adj; print=false)
    print && println("flood_fill(coords, $adj)")
    
    coords_list = collect(coords)
    mins = collect(minimum(map(c -> c[i], coords_list)) for i ∈ 1:3)
    maxes = maximum(map(c -> c[1], coords_list)), maximum(map(c -> c[2], coords_list)), maximum(map(c -> c[3], coords_list))
    print && println("Mins = $mins")
    print && println("Maxes = $maxes")

    to_visit = Queue{Tuple{Int, Int, Int}}()
    cavity = Set{Tuple{Int, Int, Int}}()

    enqueue!(to_visit, adj)
    push!(cavity, adj)
    while !isempty(to_visit)
        cube = dequeue!(to_visit)
        print && println("flood_fill visiting $cube")
        for n ∈ (cube .+ δ for δ ∈ δs)
            if (n ∉ coords) && (n ∉ cavity) && inbounds(n, mins, maxes)
                push!(cavity, n)
                enqueue!(to_visit, n)
            end
        end
    end
    print && println("flood_fill finished with cavity of size $(length(cavity))")
    cavity
end

function is_enclosed(coords, space)
    coords_list = collect(coords)
    mins = collect(minimum(map(c -> c[i], coords_list)) for i ∈ 1:3)
    maxes = collect(maximum(map(c -> c[i], coords_list)) for i ∈ 1:3)
    !any(atbounds(c, mins, maxes) for c ∈ space)
end

function find_enclosed_spaces(coords; print=false)
    interior_points = Set{Tuple{Int, Int, Int}}()
    for coord ∈ coords
        for δ ∈ δs
            adj = coord .+ δ
            if adj ∉ coords && adj ∉ interior_points
                space = flood_fill(coords, adj)
                if is_enclosed(coords, space)
                    print && println("Found an interior space: $space")
                    union!(interior_points, space)
                end
            end
        end
    end
    print && println("Found interior_points: $interior_points")
    interior_points
end

function interior_open_sides(coords, interior_coords)
    n = 0
    for coord ∈ coords
        for δ ∈ δs
            if coord .+ δ ∈ interior_coords
                n += 1
            end
        end
    end
    n
end

function part2(input = read(INPUT_PATH, String); print=false)
    coords = parse_input(input)
    interior_coords = find_enclosed_spaces(coords; print=print)
    open_sides(coords) - interior_open_sides(coords, interior_coords)
end

end # module Day18