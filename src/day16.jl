module Day16
using DataStructures
using StructEquality

import Base.isequal, Base.hash

INPUT_PATH = joinpath(@__DIR__, "../data/day16.txt")

struct Valve
    name
    flow_rate
    to
end

struct State
    pos::String
    opened::Set{String}
    minutes::Int
end

function parse_input(s)
    valves = Dict{AbstractString, Valve}()
    for line ∈ split(rstrip(s), "\n")
        m = match(r"^Valve ([A-Z]+) has flow rate=(\d+); tunnels? leads? to valves? (.*)$", line)
        if m === nothing
            println("line = $line")
        end
        valve_name = m.captures[1]
        flow_rate = parse(Int, m.captures[2])
        to = map(strip, split(m.captures[3], ","))
        valves[valve_name] = Valve(valve_name, flow_rate, to)
    end
    valves
end

function get_neighbors(state, valves, n_useful_valves)
    # if we're out of time, no more states
    if state.minutes == 0
        return State[]
    end

    # If we've already opened all the valves, do nothing
    if length(state.opened) == n_useful_valves
        return [State(state.pos, state.opened, state.minutes - 1)]
    end

    neighbors = State[]
    # Open the valve where we're standing
    if state.pos ∉ state.opened
        push!(neighbors, State(state.pos, union(state.opened, [state.pos]), state.minutes - 1))
    end
    # Go to another valve
    push!(neighbors, (State(valve_name, state.opened, state.minutes - 1) for valve_name ∈ valves[state.pos].to)...)
    neighbors
end

function additional_score(old_state::State, new_state::State, valves)
    added = setdiff(new_state.opened, old_state.opened)
    n = 0
    for new_valve ∈ added
        n += new_state.minutes * valves[new_valve].flow_rate
    end
    n
end

function part1_try1(input = read(INPUT_PATH, String))
    valves = parse_input(input)
    n_useful_valves = count(v -> v.flow_rate > 0, values(valves))
    
    initial = State("AA", Set{String}(), 30)
    to_visit = Queue{State}()
    seen = Set{State}()
    # Map from (curent_position, set_of_opened_gates) to total_flow_earned_so_far
    # includes all flow already done and also all flow that will come from open valves
    current_best = Dict{Tuple{String, Set{String}}, Int}()
    current_best[(initial.pos, initial.opened)] = 0
    enqueue!(to_visit, initial)
    prev_minute = 30
    while !isempty(to_visit)
        state = dequeue!(to_visit)
        if state.minute != prev_minute
            prev_minute = state.minute
            println("processing minute $prev_minute")
        end
        neighbors = get_neighbors(state, valves, n_useful_valves)
        for n ∈ neighbors
            flow_earned = current_best[(state.pos, state.opened)] + additional_score(state, n, valves)
            if flow_earned > get(current_best, n, typemin(Int))
                current_best[(n.pos, n.opened)] = flow_earned
                if n ∉ seen
                    push!(seen, n)
                    enqueue!(to_visit, n)
                end
            end
        end
    end
    maximum(values(current_best))
end

function floyd_warshall(W)
    n = size(W, 1)
    Dprev = map(v ->
        if v == true
            1.0
        else
            Inf
        end,
        W)
    # Set distance to self to 0 for all vertices
    for i ∈ 1:n
        Dprev[i, i] = 0.0
    end

    for k ∈ 1:n
        D = fill(Inf, (n, n))
        for i ∈ 1:n
            for j ∈ 1:n
                D[i, j] = min(Dprev[i, j], Dprev[i, k] + Dprev[k, j])
            end
        end
        Dprev = D
    end
    return map(Int, Dprev)
end

function part1_try2(input = read(INPUT_PATH, String))
    valves = parse_input(input)
    n = length(valves)

    # Construct a mapping from row of adjacency matrix to name
    names = Dict{Int, String}()
    # a mapping from name to row of adjacency matrix
    rows = Dict{String, Int}()
    for (i, v) ∈ enumerate(keys(valves))
        names[i] = v
        rows[v] = i
    end

    # Construct a dictionary where flows[i] = the flow_rate for row i in the adjacency matrix
    flows = [valves[names[i]].flow_rate for i ∈ 1:n]

    # Construct an adjacency matrix
    W = fill(false, (n, n))
    for i ∈ 1:n
        row_valve = valves[names[i]]
        for j ∈ 1:n
            W[i, j] = names[j] ∈ row_valve.to
        end
    end

    D = floyd_warshall(W)
    # println(D)

    # Greedy algorithm
    minutes = 30
    row = rows["AA"]
    total_flow = 0
    opened = Set{Int}()
    while minutes > 0
        # println("Minute $minutes, start on row $(names[row]).")
        ds = D[row, :]
        # account for the minute to turn the valve off
        total_flows = (minutes - 1 .- ds) .* flows
        target = argmax(total_flows)
        total_flow += total_flows[target]
        # println("Travel to row $(names[target]), $(ds[target]) minutes away.")
        # println("At $(minutes - ds[target]) minutes, turn off $(names[target])")
        minutes -= ds[target] + 1
        flows[target] = 0
        row = target
    end
    total_flow
end
# Greedy algorithm doesn't work.

struct EfficientState
    pos::Int
    opened::BitSet
    flow_per_minute::Int
    minutes::Int
end

# This function is an unfortunate workaround for the fact that Julia uses
# object IDs for hash and isequal on a struct (even an immutable struct).
# Tuple doesn't behave this way, so I can transform a state to a tuple to
# get dictionaries to behave as expected.
function key(state::EfficientState)
    (state.pos, state.opened, state.flow_per_minute, state.minutes)
end

function reconstruct_path(prev::Dict{Tuple{Int, BitSet, Int, Int}, EfficientState}, last::Tuple{Int, BitSet, Int, Int})
    state = EfficientState(last[1], last[2], last[3], last[4])
    path = EfficientState[]
    while state !== nothing
        pushfirst!(path, state)
        state = get(prev, key(state), nothing)
    end
    path
end

function print_path(path, names, flows, minutes)
    for state ∈ path
        if state === nothing
            continue
        end
        println("== Minute $(minutes - state.minutes + 1) ==")
        println("At valve $(names[state.pos])")
        println("Valves $(map(i -> names[i], collect(state.opened))) are open, releasing $(sum(flows[i] for i ∈ state.opened; init=0)) pressure.\n")
    end
end

function print_allpaths(D, names)
    print("  ")
    for i ∈ axes(D, 2)
        print(" $(names[i][1])")
    end
    print('\n')
    for y ∈ axes(D, 2)
        print("$(names[y])")
        for x ∈ axes(D, 1)
            print(" $(D[x, y])")
        end
        print('\n')
    end
end

function get_neighbors3(state, flows, ds, nonzero_flows)
    neighbors = EfficientState[]
    # If we're at a valve with 0 flow or a valve we've already opened, move on.
    if flows[state.pos] == 0 || state.pos ∈ state.opened
        for (i, f) ∈ enumerate(flows)
            # Consider moving to another node if it:
            # - isn't where we're at currently
            # - isn't already open
            # - has a non-zero flow
            # - we can move to it within the number of minutes
            if i != state.pos && i ∉ state.opened && f != 0 && ds[i] < state.minutes
                n = EfficientState(i, state.opened, state.flow_per_minute, state.minutes - ds[i])
                push!(neighbors, n)
            end
        end
    else
        # If we're at a closed valve with >0 flow, open it.
        n = EfficientState(
            state.pos,
            union(state.opened, state.pos),
            state.flow_per_minute + flows[state.pos],
            state.minutes - 1)
        push!(neighbors, n)
    end

    # If we're done opening all the valves but there are still minutes left, go to the end.
    if state.opened == nonzero_flows && state.minutes > 0
        n = EfficientState(
            state.pos,
            state.opened,
            state.flow_per_minute,
            0
        )
        push!(neighbors, n)
    end
    neighbors
end

function part1_try3(input = read(INPUT_PATH, String); minutes=30, print=false)
    valves = parse_input(input)
    n = length(valves)

    # Construct a mapping from row of adjacency matrix to name
    names = Dict{Int, String}()
    # a mapping from name to row of adjacency matrix
    rows = Dict{String, Int}()
    for (i, v) ∈ enumerate(keys(valves))
        names[i] = v
        rows[v] = i
    end

    # Construct an array where flows[i] = the flow_rate for row i in the adjacency matrix
    flows = [valves[names[i]].flow_rate for i ∈ 1:n]

    # Construct an adjacency matrix
    W = fill(false, (n, n))
    for i ∈ 1:n
        row_valve = valves[names[i]]
        for j ∈ 1:n
            W[i, j] = names[j] ∈ row_valve.to
        end
    end

    # Use the Floyd Warshall algorithm to find all-pairs shortest paths
    D = floyd_warshall(W)

    # Make a bitset of all the nonzero flows
    nonzero_flows = BitSet(findall(f -> f > 0, flows))

    # BFS through the valves with nonzero flows
    Q = Queue{EfficientState}()
    explored = Set{Tuple{Int, BitSet, Int, Int}}()
    root = EfficientState(rows["AA"], BitSet(), 0, minutes)
    push!(explored, key(root))
    enqueue!(Q, root)

    total_flows = Dict{Tuple{Int, BitSet, Int, Int}, Int}()
    total_flows[key(root)] = 0
    prev = Dict{Tuple{Int, BitSet, Int, Int}, EfficientState}()

    while !isempty(Q)
        state = dequeue!(Q)

        # Add neighbor states attained by moving
        neighbors = get_neighbors3(state, flows, D[state.pos, :], nonzero_flows)
        for n ∈ neighbors
            kn = key(n)
            if kn ∉ explored
                total_flows[kn] = total_flows[key(state)] + state.flow_per_minute * (state.minutes - n.minutes)
                prev[kn] = state
                enqueue!(Q, n)
            end
        end
    end
    best_last = nothing
    best_total_flow = 0
    for pair ∈ total_flows
        last, total_flow = pair
        if total_flow > best_total_flow
            best_last = last
            best_total_flow = total_flow
        end
    end
    path = reconstruct_path(prev, best_last)
    print_path(path, names, flows, minutes)
    best_total_flow
end

function flow_this_round(flows::Vector{Int}, opened::BitSet)
    n = 0
    for valve ∈ opened
        n += flows[valve]
    end
    n
end

function find_best_recursive(pos::Int, flows::Vector{Int}, opened::BitSet, minutes_remaining::Int, pressure_released_so_far::Int, nonzero_flows::BitSet, D)
    # base case
    if minutes_remaining == 0
        return pressure_released_so_far
    elseif minutes_remaining == 1
        return pressure_released_so_far + flow_this_round(flows, opened)
    elseif flows[pos] > 0 && pos ∉ opened
        return find_best_recursive(pos, flows, union(opened, pos), minutes_remaining - 1, pressure_released_so_far + flow_this_round(flows, opened), nonzero_flows, D)
    else
        ds = D[pos, :]
        best_total_flow = 0
        best_move = nothing
        for next ∈ setdiff(nonzero_flows, opened)
            total_flow = find_best_recursive(pos, flows, opened, minutes_remaining - ds[next], pressure_released_so_far + flow_this_round(flows, opened), nonzero_flows, D)
            if total_flow > best_total_flow
                best_total_flow = total_flow
                best_move = next
            end
        end
        return best_total_flow
    end
end

function part1_try4(input = read(INPUT_PATH, String); minutes=30, print=false)
    valves = parse_input(input)
    n = length(valves)

    # Construct a mapping from row of adjacency matrix to name
    names = Dict{Int, String}()
    # a mapping from name to row of adjacency matrix
    rows = Dict{String, Int}()
    for (i, v) ∈ enumerate(keys(valves))
        names[i] = v
        rows[v] = i
    end

    # Construct an array where flows[i] = the flow_rate for row i in the adjacency matrix
    flows = [valves[names[i]].flow_rate for i ∈ 1:n]

    # Construct an adjacency matrix
    W = fill(false, (n, n))
    for i ∈ 1:n
        row_valve = valves[names[i]]
        for j ∈ 1:n
            W[i, j] = names[j] ∈ row_valve.to
        end
    end

    # Use the Floyd Warshall algorithm to find all-pairs shortest paths
    D = floyd_warshall(W)

    # Make a bitset of all the nonzero flows
    nonzero_flows = BitSet(findall(f -> f > 0, flows))

    find_best_recursive(rows["AA"], flows, BitSet(), minutes, 0, nonzero_flows, D)
end

end # module Day16