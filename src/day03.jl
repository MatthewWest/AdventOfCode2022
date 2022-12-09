module Day03
export part1, part2

INPUT_PATH = joinpath(@__DIR__, "../data/day03.txt")

function parse_input(s)
	lines = split(s, "\n")
	rucksacks = []
	for line ∈ lines
		n = length(line)
		if n == 0
			continue
		end
		first = line[1:(n ÷ 2)]
		second = line[(n÷2+1):n]
		push!(rucksacks, (first, second))
	end
	rucksacks
end

function priority(c)
	if c >= 'a' && c <= 'z'
		return c - 'a' + 1
	elseif c >= 'A' && c <= 'Z'
		return c - 'A' + 27
	end
end

function part1(input = read(INPUT_PATH, String))
	sacks = parse_input(input)
	common = [only(intersect(sack[1], sack[2])) for sack ∈ sacks]
	
	sum(priority.(common))
end

function part2(input = read(INPUT_PATH, String))
	groups = Iterators.partition(split(rstrip(input), "\n"), 3)
	badges = [only(intersect(group[1], group[2], group[3])) for group ∈ groups]
	sum(priority.(badges))
end

end # module Day03