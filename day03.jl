### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ 5817d752-7386-11ed-0398-cd37bab030a6
function get_input(s)
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

# ╔═╡ c47136f3-81ec-4ca1-b3b0-bcde4fd37e55
function get_from_file(filename)
	get_input(read(filename, String))
end

# ╔═╡ 0732a062-637b-49a0-830a-7c659cd0b2c0
get_from_file("day03testinput.txt")

# ╔═╡ 971e6989-b18b-4b0b-ad2c-173b72bf9e5e
function priority(c)
	if c >= 'a' && c <= 'z'
		return c - 'a' + 1
	elseif c >= 'A' && c <= 'Z'
		return c - 'A' + 27
	end
end

# ╔═╡ 2bb376d0-fe38-4964-9c85-a24e3576e281
function part1(filename = "day03input.txt")
	sacks = get_from_file(filename)
	common = [only(intersect(sack[1], sack[2])) for sack ∈ sacks]
	
	sum(priority.(common))
end

# ╔═╡ 03e58b3a-6193-4ffd-b9d0-1e41305c3baa
part1()

# ╔═╡ e1395a19-972f-43df-8688-8971d446c9c4
function part2(filename = "day03input.txt")
	groups = Iterators.partition(readlines(filename), 3)
	badges = [only(intersect(group[1], group[2], group[3])) for group ∈ groups]
	sum(priority.(badges))
end

# ╔═╡ 77fa6711-c000-4b14-9717-a1c056b9d47d
part2()

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "da39a3ee5e6b4b0d3255bfef95601890afd80709"

[deps]
"""

# ╔═╡ Cell order:
# ╠═5817d752-7386-11ed-0398-cd37bab030a6
# ╠═c47136f3-81ec-4ca1-b3b0-bcde4fd37e55
# ╠═0732a062-637b-49a0-830a-7c659cd0b2c0
# ╠═971e6989-b18b-4b0b-ad2c-173b72bf9e5e
# ╠═2bb376d0-fe38-4964-9c85-a24e3576e281
# ╠═03e58b3a-6193-4ffd-b9d0-1e41305c3baa
# ╠═e1395a19-972f-43df-8688-8971d446c9c4
# ╠═77fa6711-c000-4b14-9717-a1c056b9d47d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
