module Day10

INPUT_PATH = joinpath(@__DIR__, "../data/day10.txt")

abstract type Instr end

struct Noop <: Instr
end

struct Addx <: Instr
    V::Int
end

mutable struct State
    X::Int
    cycle::Int
    pc::Int
    running::Union{Nothing, Tuple{Instr, Int}}
end

num_cycles(instr::Noop) = 1
num_cycles(instr::Addx) = 2

apply!(state::State, instr::Instr) = nothing
function apply!(state::State, instr::Addx)
    state.X += instr.V
end

function start_tick!(state::State, program::AbstractArray{Instr})
    if state.running === nothing
        state.running = program[state.pc], 1
    else
        instr, n = state.running
        state.running = instr, n + 1
    end
end

function end_tick!(state::State)
    instr, n_cycle = state.running
    if n_cycle == num_cycles(instr)
        apply!(state, instr)
        state.pc += 1
        state.running = nothing
    end
    state.cycle += 1
end

function parse_input(s)
    lines = split(rstrip(s), "\n")
    instrs = Instr[]
    for line ∈ lines
        if line == "noop"
            push!(instrs, Noop())
        elseif startswith(line, "addx")
            parts = split(line)
            push!(instrs, Addx(parse(Int, parts[2])))
        end
    end
    instrs
end


function run_program(program; interesting=c -> false, run_each_cycle=s -> nothing)
    signal_strengths = Int[]
    state = State(1, 1, 1, nothing)
    while true
        if state.pc > length(program)
            break
        end
        start_tick!(state, program)
        if interesting(state.cycle)
            push!(signal_strengths, state.cycle * state.X)
        end
        run_each_cycle(state)
        end_tick!(state)
    end
    signal_strengths
end

function part1(input = read(INPUT_PATH, String))
    program = parse_input(input)
    interesting_cycles = Set([20, 60, 100, 140, 180, 220])
    run_program(program; interesting = c -> c ∈ interesting_cycles) |> sum
end

function pixel(state::State)
    col = (state.cycle - 1) % 40
    if abs(state.X - col) <= 1
        "#"
    else
        "."
    end
end

function string_state(state::State)
    s = pixel(state)
    col = (state.cycle - 1) % 40
    if col == 39
        s *= "\n"
    end
    s
end

function part2(input = read(INPUT_PATH, String); print=true)
    program = parse_input(input)
    s = ""
    function accumulate_output(state::State)
        s *= string_state(state)
    end
    run_program(program; run_each_cycle = accumulate_output)
    if print
        print(s)
    end
    s
end

end # module Day10