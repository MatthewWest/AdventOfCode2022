module Day11

using OffsetArrays

INPUT_PATH = joinpath(@__DIR__, "../data/day11.txt")

mutable struct Monkey
    items::Vector{Int}
    operation::Function
    test::Function
    cumulative_inspected_items::Int
end

function parse_operation(s)
    tokens = split(s)
    op_s, right = tokens[end-1], tokens[end]
    if op_s == "*"
        op = *
    elseif op_s == "+"
        op = +
    end
    if right == "old"
        return x -> op(x, x)
    else
        n = parse(Int, right)
        return x -> op(x, n)
    end
end

function parse_test(lines)
    divisor = parse(Int, split(lines[1])[end])
    true_target = parse(Int, split(lines[2])[end])
    false_target = parse(Int, split(lines[3])[end])
    function f(worry_level::Int)::Int
        if worry_level % divisor == 0
            return true_target
        else
            return false_target
        end
    end
    return f, divisor
end

function parse_input(s)
    monkey_strings = split(rstrip(s), "\n\n")
    monkeys = OffsetArrays.Origin(0)(Monkey[])
    i = 0
    divisors = Int[]
    for monkey ∈ monkey_strings
        lines = split(rstrip(monkey), "\n")
        items_line = strip(lines[2])
        items_part = match(r"^Starting items: (.*)$", items_line)
        items = parse.(Int, split(items_part.captures[1], ","))
        operation_part = match(r"^Operation:(.*)$", strip(lines[3]))
        operation = parse_operation(operation_part.captures[1])
        test, divisor  = parse_test(lines[4:end])
        push!(divisors, divisor)
        push!(monkeys, Monkey(items, operation, test, 0))
        i += 1
    end
    monkeys, lcm(divisors...)
end

function do_turn1!(monkeys, monkey)
    while ! isempty(monkey.items)
        item = popfirst!(monkey.items)
        monkey.cumulative_inspected_items += 1
        new_item_worry = monkey.operation(item) ÷ 3
        new_monkey = monkey.test(new_item_worry)
        push!(monkeys[new_monkey].items, new_item_worry)
    end
end

function do_round1!(monkeys)
    for i ∈ eachindex(monkeys)
        do_turn1!(monkeys, monkeys[i])
    end
end

function print_monkeys(monkeys)
    for i ∈ eachindex(monkeys)
        println("Monkey $i holds $(monkeys[i].items)")
    end
end

function print_monkey_counts(monkeys)
    for i ∈ eachindex(monkeys)
        println("Monkey $i inspected items $(monkeys[i].cumulative_inspected_items) times.")
    end
end

function do_turn2!(monkeys, monkey, mod)
    while ! isempty(monkey.items)
        item = popfirst!(monkey.items)
        monkey.cumulative_inspected_items += 1
        new_item_worry = monkey.operation(item) % mod
        new_monkey = monkey.test(new_item_worry)
        push!(monkeys[new_monkey].items, new_item_worry)
    end
end

function do_round2!(monkeys, mod)
    for i ∈ eachindex(monkeys)
        do_turn2!(monkeys, monkeys[i], mod)
    end
end


function part1(input = read(INPUT_PATH, String))
    monkeys, _ = parse_input(input)
    for _ ∈ 1:20
        do_round1!(monkeys)
    end
    items_processed = map(m -> m.cumulative_inspected_items, monkeys)
    partialsort!(items_processed, 2; rev=true)
    prod(first(items_processed, 2))
end

function part2(input = read(INPUT_PATH, String))
    monkeys, mod = parse_input(input)
    for _ ∈ 1:10000
        do_round2!(monkeys, mod)
    end
    items_processed = map(m -> m.cumulative_inspected_items, monkeys)
    partialsort!(items_processed, 2; rev=true)
    prod(first(items_processed, 2))
end
end # module Day11
