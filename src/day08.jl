module Day08
export part1, part2	

INPUT_PATH = joinpath(@__DIR__, "../data/day08.txt")

function parse_input(s)
	s = rstrip(s)
	lines = split(s, "\n")
	m, n = length(lines), length(lines[1])
	grid = Array{Int, 2}(undef, (m, n))
	for (i, line) ∈ enumerate(lines)
		for (j, c) ∈ enumerate(line)
			grid[i, j] = parse(Int, c)
		end
	end
	grid
end

function visible_dir(grid, coord, step)
	height = grid[coord...]
	x, y = coord
	dx, dy = step
	xi, yi = x + dx, y + dy
	while checkbounds(Bool, grid, xi, yi)
		if grid[xi, yi] >= height
			return false
		end
		xi += dx
		yi += dy
	end
	return true
end

function visible(grid, coord)
	for step ∈ [(1, 0), (-1, 0), (0, 1), (0, -1)]
		if visible_dir(grid, coord, step)
			return true
		end
	end
	return false
end

function part1(s = read(INPUT_PATH, String))
	grid = parse_input(s)
	n = 0
	for I ∈ CartesianIndices(grid)
		if visible(grid, Tuple(I))
			n += 1
		end
	end
	n
end


function count_trees_dir(grid, coord, step)
	height = grid[coord...]
	x, y = coord
	dx, dy = step
	xi, yi = x + dx, y + dy
	n = 0
	while checkbounds(Bool, grid, xi, yi)
		n += 1
		if grid[xi, yi] >= height
			break
		end
		xi += dx
		yi += dy
	end
	return n
end

function scenic_score(grid, coord)
	score = 1
	for step ∈ [(1, 0), (-1, 0), (0, 1), (0, -1)]
		score *= count_trees_dir(grid, coord, step)
	end
	score
end

function part2(s = read(INPUT_PATH, String))
	grid = parse_input(s)
	highest = -1
	for I ∈ CartesianIndices(grid)
		score = scenic_score(grid, Tuple(I))
		if score > highest
			highest = score
		end
	end
	highest
end

end # module Day08
