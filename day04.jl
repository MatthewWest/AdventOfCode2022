### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ cdaafce0-73dd-11ed-3d96-49eef92a208a
function get_input(filename)
	lines = readlines(filename)
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

# ╔═╡ fb0af2af-e83a-4eda-be84-77eecbfe2523
function fully_overlap(a, b)
	first(a) in b && last(a) in b || first(b) in a && last(b) in a
end

# ╔═╡ 396e192b-82fc-44d1-8f5a-f42d9a4fe83c
function part1(filename = "day04input.txt")
	input = get_input(filename)
	count(pair -> fully_overlap(pair[1], pair[2]), input)
end

# ╔═╡ 68714ee9-dbfc-4ad8-bb69-01aee3cd0145
part1()

# ╔═╡ 7664ec4f-d409-4753-a922-c8750624d51a
function partly_overlap(a, b)
	first(a) in b || last(a) in b || first(b) in a || last(b) in a
end

# ╔═╡ 12f2feaa-a2ef-418e-86a8-04c05b48c457
function part2(filename = "day04input.txt")
	input = get_input(filename)
	count(pair -> partly_overlap(pair[1], pair[2]), input)
end

# ╔═╡ 3c76ffa2-cd98-4191-9478-b1cc7274d9d0
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
# ╠═cdaafce0-73dd-11ed-3d96-49eef92a208a
# ╠═fb0af2af-e83a-4eda-be84-77eecbfe2523
# ╠═396e192b-82fc-44d1-8f5a-f42d9a4fe83c
# ╠═68714ee9-dbfc-4ad8-bb69-01aee3cd0145
# ╠═7664ec4f-d409-4753-a922-c8750624d51a
# ╠═12f2feaa-a2ef-418e-86a8-04c05b48c457
# ╠═3c76ffa2-cd98-4191-9478-b1cc7274d9d0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
