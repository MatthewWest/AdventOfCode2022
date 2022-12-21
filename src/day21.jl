module Day21

using Symbolics

INPUT_PATH = joinpath(@__DIR__, "../data/day21.txt")

struct Operation
    a::String
    b::String
    op::Function
end

struct Monkey
    to_tell::Union{Int, Operation}
end

function parse_operator(c)
    if c == "+"
        +
    elseif c == "-"
        -
    elseif c == "/"
        # We use the // operator to stay in integers / rationals.
        # ÷ also works, but it doesn't work with Symbolics.jl.
        //
    elseif c == "*"
        *
    end
end

function parse_input1(s)
    lines = split(rstrip(s), "\n")
    monkeys = Dict{String, Monkey}()

    for line ∈ lines
        name, to_tell = split(line, ":")

        number = tryparse(Int, to_tell)
        if number !== nothing
            monkeys[name] = Monkey(number)
            continue
        end

        m = match(r"([a-z]{4}) ([-*+/]) ([a-z]{4})", strip(to_tell))
        a, opstring, b = m.captures
        if a === nothing || opstring === nothing || b === nothing
            @error("Failed to parse $line")
        end
        monkeys[name] = Monkey(Operation(a, b, parse_operator(opstring)))
    end
    monkeys
end

function eval1(monkeys, name)
    m = monkeys[name]
    if typeof(m.to_tell) == Int
        return m.to_tell
    else
        return m.to_tell.op(eval1(monkeys, m.to_tell.a), eval1(monkeys, m.to_tell.b))
    end
end

function part1(input = read(INPUT_PATH, String))
    monkeys = parse_input1(input)
    Int(eval1(monkeys, "root"))
end

struct SymbolicOperation
    a::Union{AbstractString, Num}
    b::Union{AbstractString, Num}
    op::Function
end

struct SymbolicMonkey
    to_tell::Union{Int, SymbolicOperation}
end

function parse_input2(s)
    lines = split(rstrip(s), "\n")
    @variables humn
    # Symbolics returns type Num, which is <: Real
    monkeys = Dict{String, SymbolicMonkey}()

    for line ∈ lines
        name, to_tell = split(line, ":")
        if name == "humn"
            continue
        end

        number = tryparse(Int, to_tell)
        if number !== nothing
            monkeys[name] = SymbolicMonkey(number)
            continue
        end

        m = match(r"([a-z]{4}) ([-*+/]) ([a-z]{4})", strip(to_tell))
        a, opstring, b = m.captures
        if a == "humn"
            a = humn
        end
        if b == "humn"
            b = humn
        end
        if a === nothing || opstring === nothing || b === nothing
            @error("Failed to parse $line")
        end
        monkeys[name] = SymbolicMonkey(SymbolicOperation(a, b, parse_operator(opstring)))
    end
    monkeys, humn
end

function eval2(monkeys, name::AbstractString, humn)
    if name == humn
        return humn
    end
    m = monkeys[name]
    if typeof(m.to_tell) <: Real
        return m.to_tell
    else
        if typeof(m.to_tell.a) == Num
            a = m.to_tell.a
        else
            a = eval2(monkeys, m.to_tell.a, humn)
        end

        if typeof(m.to_tell.b) == Num
            b = m.to_tell.b
        else
            b = eval2(monkeys, m.to_tell.b, humn)
        end

        return m.to_tell.op(a, b)
    end
end

function part2(input = read(INPUT_PATH, String))
    monkeys, humn = parse_input2(input)

    root = monkeys["root"]
    left = eval2(monkeys, root.to_tell.a, humn)
    right = eval2(monkeys, root.to_tell.b, humn)
    x = Symbolics.value(Symbolics.solve_for(left - right ~ 0, humn))
    if isinteger(x)
        Int(x)
    else
        @error("Not an integer output")
    end
end

end # module Day21