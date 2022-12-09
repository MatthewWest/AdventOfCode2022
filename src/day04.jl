module Day04
export part1, part2

INPUT_PATH = joinpath(@__DIR__, "../data/day04.txt")

function parse_input(s)
	lines = split(s, "\n")
	pairs = []
	for line in lines
		if isempty(line)
			continue
		end
		m = match(r"^(\d+)-(\d+),(\d+)-(\d+)$", line)
		r1 = parse(Int, m.captures[1]):parse(Int, m.captures[2])
		r2 = parse(Int, m.captures[3]):parse(Int, m.captures[4])
		push!(pairs, (r1, r2))
	end
	pairs
end

function fully_overlap(a, b)
	first(a) in b && last(a) in b || first(b) in a && last(b) in a
end

function part1(input = read(INPUT_PATH, String))
	input = parse_input(rstrip(input))
	count(pair -> fully_overlap(pair[1], pair[2]), input)
end

function partly_overlap(a, b)
	first(a) in b || last(a) in b || first(b) in a || last(b) in a
end

function part2(input = read(INPUT_PATH, String))
	input = parse_input(rstrip(input))
	count(pair -> partly_overlap(pair[1], pair[2]), input)
end

end # module Day04
