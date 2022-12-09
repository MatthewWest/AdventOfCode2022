module Day05
export part1, part2

using DataStructures

INPUT_PATH = joinpath(@__DIR__, "../data/day05.txt")

struct Command
	num::Int
	src::Int
	dest::Int
end

function parse_input(s)
	sts, cmds = split(s, "\n\n")
	stacks = []
	stack_lines = split(sts, "\n")
	for _ ∈ eachmatch(r"\d+", last(stack_lines))
		push!(stacks, Stack{Char}())
	end
	for line ∈ reverse(stack_lines[1:end-1])
		for i ∈ eachindex(stacks)
			pos = (i-1)*4+1
			box = line[pos:pos+2]
			m = match(r"^(?:\[([A-Z])\]|   )$", box) 
			if m === nothing
				error("Box did not match $box")
			end
			if box == "   "
				continue
			end
			push!(stacks[i], m.captures[1][1])
		end
	end
	commands = []
	for cmd ∈ split(cmds, "\n")
		m = match(r"move (\d+) from (\d) to (\d)", cmd)
		if m === nothing
			continue
		end
		push!(commands, Command(map(n -> parse(Int, n), m.captures)...))
	end
	stacks, commands
end

function apply1(stacks, cmd)
	for _ ∈ 1:cmd.num
		push!(stacks[cmd.dest], pop!(stacks[cmd.src]))
	end
end

function part1(s = read(INPUT_PATH, String))
	stacks, cmds = parse_input(s)
	for cmd ∈ cmds
		apply1(stacks, cmd)
	end
	join(first.(stacks))
end

function apply2(stacks, cmd)
	moving = Char[]
	for _ ∈ 1:cmd.num
		push!(moving, pop!(stacks[cmd.src]))
	end
	for el ∈ reverse(moving)
		push!(stacks[cmd.dest], el)
	end
end

function part2(s = read(INPUT_PATH, String))
	stacks, cmds = parse_input(s)
	for cmd ∈ cmds
		apply2(stacks, cmd)
	end
	join(first.(stacks))
end

end # module Day05