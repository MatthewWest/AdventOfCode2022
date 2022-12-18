module Day16
using DataStructures

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
    minutes::Int
end

function part1_try3(input = read(INPUT_PATH, String))
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
    to_visit = Queue{EfficientState}()
    initial = EfficientState(rows["AA"], BitSet(), 30)
    println("Initial state is $initial")
    enqueue!(to_visit, initial)
    best_total_flows = Dict{EfficientState, Int}()
    best_total_flows[initial] = 0
    
    while !isempty(to_visit)
        state = dequeue!(to_visit)
        # println("At $(names[state.pos]), total flow earned so far is $(best_total_flows[state])")

        # Add neighbor states attained by moving
        ds = D[state.pos, :]
        # If we're at a valve we could open, don't move on unless it's opened
        if state.pos ∈ state.opened
            for (i, f) ∈ enumerate(flows)
                # Consider moving to another node if it:
                # - isn't already open
                # - has a non-zero flow
                # - we can move to it within the number of minutes
                if i ∈ state.opened || f == 0 || ds[i] >= state.minutes
                    continue
                end
                n = EfficientState(i, state.opened, state.minutes - ds[i])
                # Explore the neighbor if we haven't reached that state yet
                if n ∉ keys(best_total_flows)
                    best_total_flows[n] = best_total_flows[state]
                    enqueue!(to_visit, n)
                end
            end
        end
        # Add neighbor state attained by opening the valve if the current position isn't open
        if state.pos ∉ state.opened
            n = EfficientState(state.pos, union(state.opened, state.pos), state.minutes)
            best_total_flows[n] = best_total_flows[state] + n.minutes * flows[n.pos]
            # If we've opened all the valves with nonzero flow, don't keep searching.
            if n.opened == nonzero_flows
                continue
            end
            enqueue!(to_visit, n)
        end
    end
    maximum(values(best_total_flows))
end

end # module Day16