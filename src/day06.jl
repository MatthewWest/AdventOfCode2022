module Day06
export part1, part2

INPUT_PATH = joinpath(@__DIR__, "../data/day06.txt")

function n_unique(s, n)
	for i in n:length(s)
		if allunique(s[i-(n-1):i])
			return i
		end
	end
end

function part1(s = read(INPUT_PATH, String))
	n_unique(s, 4)
end

function part2(s = read(INPUT_PATH, String))
	n_unique(s, 14)
end

end # module Day06