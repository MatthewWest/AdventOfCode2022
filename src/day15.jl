module Day15

INPUT_PATH = joinpath(@__DIR__, "../data/day15.txt")

using GeometryBasics
using LinearAlgebra: det
using OffsetArrays
using Plots

function parse_input(s)
    nearest = Dict{CartesianIndex, CartesianIndex}()
    for line ∈ split(rstrip(s), "\n")
        sensor, beacon = split(line, ":")
        sensor_pos = map(d -> parse(Int, d), match(r"x=(-?\d+), y=(-?\d+)", sensor).captures) |> Tuple |> CartesianIndex
        beacon_pos = map(d -> parse(Int, d), match(r"x=(-?\d+), y=(-?\d+)", beacon).captures) |> Tuple |> CartesianIndex
        nearest[sensor_pos] = beacon_pos
    end
    nearest
end

function manhattan_dist(a::CartesianIndex, b::CartesianIndex)::Int
    abs(a[1] - b[1]) + abs(a[2] - b[2])
end

function impossible_squares_row(nearest_beacons, yrow)
    dists = Dict{CartesianIndex, Int}(a => manhattan_dist(a, b) for (a, b) ∈ nearest_beacons)
    sensors = collect(keys(nearest_beacons))
    nearest_sensors = Dict{CartesianIndex, CartesianIndex}()
    for sensor ∈ sensors
        dist = dists[sensor]
        sx, sy = sensor[1], sensor[2]
        xdist = dist - abs(yrow - sy)
        if xdist > dists[sensor]
            continue
        end

        for x ∈ (sx - xdist):(sx + xdist)
            nearest_sensors[CartesianIndex(x, yrow)] = sensor
        end
    end
    
    keys(nearest_sensors)
end

function part1(input = read(INPUT_PATH, String); yrow=2000000)
    nearest_beacons = parse_input(input)
    determined_squares = impossible_squares_row(nearest_beacons, yrow)
    beacons = Set(values(nearest_beacons))

    xs = [i[1] for i in determined_squares]
    maxx, minx = maximum(xs), minimum(xs)
    n = 0
    for x ∈ minx:maxx
        coord = CartesianIndex(x, yrow)
        if coord ∉ beacons && coord ∈ determined_squares
            n += 1
        end
    end
    n
end

function part2_try1(input = read(INPUT_PATH, String); mincoord=0, maxcoord=4000000)
    nearest_beacons = parse_input(input)
    dists = Dict{CartesianIndex, Int}(a => manhattan_dist(a, b) for (a, b) ∈ nearest_beacons)
    sensors = keys(nearest_beacons)
    search_space = CartesianIndices((mincoord:maxcoord, mincoord:maxcoord))
    for I ∈ search_space
        possible = true
        for sensor ∈ sensors
            if manhattan_dist(I, sensor) <= dists[sensor]
                possible = false
                break
            end
        end
        if possible
            return I[1] * 4000000 + I[2]
        end
    end
end

function fill_impossible!(possible_map, sensor, beacon)
    minx, maxx = firstindex(possible_map, 1), lastindex(possible_map, 1)
    miny, maxy = firstindex(possible_map, 2), lastindex(possible_map, 2)
    dist = manhattan_dist(sensor, beacon)
    for x ∈ max(sensor[1] - dist, minx):min(sensor[1] + dist, maxx)
        ydist = dist - abs(x - sensor[1])
        for y ∈ max(sensor[2] - ydist, miny):min(sensor[2] + ydist, maxy)
            I = CartesianIndex(x, y)
            possible_map[I] = false
        end
    end
end

function part2_try2(input = read(INPUT_PATH, String); mincoord=0, maxcoord=4000000)
    nearest_beacons = parse_input(input)
    possible_map = OffsetArrays.Origin(0)(fill(true, (maxcoord+1, maxcoord+1)))
    for sensor ∈ keys(nearest_beacons)
        fill_impossible!(possible_map, sensor, nearest_beacons[sensor])
    end
    I::CartesianIndex = findfirst(possible_map)
    I[1] * 4000000 + I[2]
end

struct Zone
    tip_n::CartesianIndex
    tip_s::CartesianIndex
    tip_e::CartesianIndex
    tip_w::CartesianIndex
end

function get_zone(sensor, beacon)
    dist = manhattan_dist(sensor, beacon)
    tip_n = CartesianIndex(Tuple(sensor) .+ (0, dist))
    tip_s = CartesianIndex(Tuple(sensor) .+ (0, -dist))
    tip_e = CartesianIndex(Tuple(sensor) .+ (dist, 0))
    tip_w = CartesianIndex(Tuple(sensor) .+ (-dist, 0))
    Zone(tip_n, tip_s, tip_e, tip_w)
end

function plot_zone(plt, zone::Zone)
    coords::Vector{Tuple{Int, Int}} = map(Tuple, [zone.tip_n, zone.tip_e, zone.tip_s, zone.tip_w, zone.tip_n])
    xs::Vector{Int} = map(p -> p[1], coords)
    ys::Vector{Int} = map(p -> p[2], coords)
    zone_shape = Shape(xs, ys)
    plot!(plt, zone_shape; fillalpha=0.2)
end

function part2_try3(input = read(INPUT_PATH, String); mincoord=0, maxcoord=4000000)
    nearest_beacons = parse_input(input)
    zones = [get_zone(sensor, beacon) for (sensor, beacon) in nearest_beacons]
    plt = plot([0, maxcoord, maxcoord, 0, 0], [0, 0, maxcoord, maxcoord, 0])
    for zone ∈ zones
        plot_zone(plt, zone)
    end
    # xlims!((mincoord, maxcoord))
    # ylims!((mincoord, maxcoord))
    plt
end

function boundary(sensor, beacon, mincoord, maxcoord)
    bound = Set{CartesianIndex}()
    dist = manhattan_dist(sensor, beacon)
    sx, sy = sensor[1], sensor[2]
    for x ∈ max(sx - dist, mincoord):min(sx + dist, maxcoord)
        ydist = dist - abs(x - sx)
        push!(bound, CartesianIndex(x, max(sy - ydist, mincoord)))
        push!(bound, CartesianIndex(x, min(sy + ydist, maxcoord)))
    end
    bound
end

# Boundaries are still too slow
function part2_try4(input = read(INPUT_PATH, String); mincoord=0, maxcoord=4000000)
    nearest_beacons = parse_input(input)
    boundaries = [boundary(s, b, mincoord, maxcoord) for (s, b) in nearest_beacons]
    boundaries[1]
end

function diamond(sensor, dist)
    bound = Set{CartesianIndex}()
    sx, sy = sensor[1], sensor[2]
    for x ∈ sx-dist:sx+dist
        ydist = dist - abs(x - sx)
        push!(bound, CartesianIndex(x, sy - ydist))
        push!(bound, CartesianIndex(x, sy + ydist))
    end
    bound
end

function part2_try5(input = read(INPUT_PATH, String); mincoord=0, maxcoord=4000000)
    nearest_beacons = parse_input(input)
    sensors = collect(keys(nearest_beacons))
    pairs = Tuple{CartesianIndex, CartesianIndex}[]
    n = length(sensors)
    for i ∈ 1:n-1
        for j ∈ i+1:n
            # println("($i, $j)")
            sa, sb = sensors[i], sensors[j]
            ba, bb = nearest_beacons[sa], nearest_beacons[sb]
            if manhattan_dist(sa, sb) == manhattan_dist(sa, ba) + 2 + manhattan_dist(sb, bb)
                push!(pairs, (sa, sb))
            end
        end
    end
    if length(pairs) == 2
        s1, s2 = pairs[1]
        s3, s4 = pairs[2]
        S1 = diamond(s1, manhattan_dist(s1, nearest_beacons[s1]) + 1)
        S2 = diamond(s2, manhattan_dist(s2, nearest_beacons[s2]) + 1)
        S3 = diamond(s3, manhattan_dist(s3, nearest_beacons[s3]) + 1)
        S4 = diamond(s4, manhattan_dist(s4, nearest_beacons[s4]) + 1)
        I = only(intersect(S1, S2, S3, S4))
        I[1] * 4000000 + I[2]
    else
        part2_try1(input; mincoord, maxcoord)
    end
end

function find_open_line(s1, s2, dists)
    points = CartesianIndex[]
    d1 = dists[s1] + 1
    d2 = dists[s2] + 1 
    push!(points, [CartesianIndex(Tuple(s1) .+ δ) for δ ∈ [(0, d1), (0, -d1), (d1, 0), (-d1, 0)]]...)
    push!(points, [CartesianIndex(Tuple(s2) .+ δ) for δ ∈ [(0, d2), (0, -d2), (d2, 0), (-d2, 0)]]...)
    
    endpoints = filter(p -> manhattan_dist(s1, p) == d1 && manhattan_dist(s2, p) == d2, points)
    @assert length(endpoints) == 2
    Tuple(endpoints)
end

function tuning_frequency(point)
    point[1] * 4000000 + point[2]
end

function intersects(a::Tuple{CartesianIndex, CartesianIndex}, b::Tuple{CartesianIndex, CartesianIndex})
    # destructure vertices
    v1, v2 = a
    v3, v4 = b
    # find slopes
    ma = (v2[2] - v1[2]) / (v2[1] - v1[1])
    mb = (v4[2] - v3[2]) / (v4[1] - v3[1])

    # Point-slope form is
    # y - y1 = m(x - x1)
    #
    # Replace m with its definition
    # y - y1 = ((y2 - y1) / (x2 - x1))(x - x1)
    #
    # Multiply out (x2 - x1)
    # y(x2 - x1) - y1(x2 - x1) = x(y2 - y1) - x1(y2 - y1)
    #
    # Move constants to the right, x and y to the left
    # (y1 - y2) * x + (x2 - x1) * y = y1(x2 - x1) - x1(y2 - y1)
    #
    # Let the system of equations be AX = B where A is the square matrix of coefficients,
    # X is the variables, and B is the column matrix of constants
    A = [
        (v1[2] - v2[2]) (v2[1] - v1[1]);
        (v3[2] - v4[2]) (v4[1] - v3[1])
    ]
    B = [
        v1[2] * (v2[1] - v1[1]) - v1[1] * (v2[2] - v1[2]);
        v3[2] * (v4[1] - v3[1]) - v3[1] * (v4[2] - v3[2])
    ]

    # If the determinant if 0, the lines are parallel
    D = det(A)
    if D == 0
        return false, nothing
    end

    # Apply cramer's rule
    D1 = det(hcat(B, A[:, 2]))
    D2 = det(hcat(A[:, 1], B))
    x, y = D1 / D, D2 / D
    @assert isinteger(x) && isinteger(y)
    return true, CartesianIndex(Int(x), Int(y))
end

function part2_efficient(input = read(INPUT_PATH, String); mincoord=0, maxcoord=4000000)
    nearest_beacons = parse_input(input)
    sensors = collect(keys(nearest_beacons))
    dists = Dict{CartesianIndex, Int}(a => manhattan_dist(a, b) for (a, b) ∈ nearest_beacons)
    solution_space = CartesianIndices((mincoord:maxcoord, mincoord:maxcoord))

    lines = Tuple{CartesianIndex, CartesianIndex}[]
    n = length(sensors)
    for i ∈ 1:n-1
        for j ∈ i+1:n
            # println("($i, $j)")
            sa, sb = sensors[i], sensors[j]
            ba, bb = nearest_beacons[sa], nearest_beacons[sb]
            if manhattan_dist(sa, sb) == manhattan_dist(sa, ba) + 2 + manhattan_dist(sb, bb)
                push!(lines, find_open_line(sa, sb, dists))
            end
        end
    end
    # Find intersections
    nlines = length(lines)
    for i ∈ 1:nlines - 1
        for j ∈ i+1:nlines
            found, point = intersects(lines[i], lines[j])
            if found && point ∈ solution_space
                return tuning_frequency(point)
            end
        end
    end
    return nothing
end

part2 = part2_efficient

end # module Day15
