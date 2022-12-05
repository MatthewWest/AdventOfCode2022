### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ 5db9900f-6b18-4f47-89fb-63663ed443b9
using DataStructures

# ╔═╡ e76416b6-39ec-4303-af11-110bd44a7d11
begin
testinput = """    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2""";
md"Test input definition."
end

# ╔═╡ 556d4562-4ecb-4f2e-84e4-ae7b3d4d71fe
begin
input = """        [J]         [B]     [T]    
        [M] [L]     [Q] [L] [R]    
        [G] [Q]     [W] [S] [B] [L]
[D]     [D] [T]     [M] [G] [V] [P]
[T]     [N] [N] [N] [D] [J] [G] [N]
[W] [H] [H] [S] [C] [N] [R] [W] [D]
[N] [P] [P] [W] [H] [H] [B] [N] [G]
[L] [C] [W] [C] [P] [T] [M] [Z] [W]
 1   2   3   4   5   6   7   8   9 

move 6 from 6 to 5
move 2 from 5 to 9
move 8 from 9 to 1
move 3 from 5 to 4
move 9 from 1 to 8
move 2 from 1 to 5
move 1 from 1 to 8
move 14 from 8 to 2
move 1 from 1 to 2
move 2 from 6 to 8
move 2 from 5 to 7
move 6 from 8 to 6
move 4 from 4 to 2
move 2 from 4 to 9
move 5 from 7 to 4
move 2 from 7 to 5
move 6 from 2 to 4
move 2 from 4 to 7
move 4 from 5 to 8
move 1 from 5 to 2
move 3 from 3 to 5
move 3 from 8 to 3
move 4 from 3 to 7
move 2 from 9 to 8
move 1 from 3 to 7
move 1 from 6 to 8
move 5 from 7 to 1
move 3 from 7 to 2
move 1 from 6 to 3
move 2 from 5 to 9
move 5 from 4 to 2
move 3 from 5 to 9
move 5 from 9 to 6
move 2 from 1 to 3
move 4 from 4 to 1
move 2 from 8 to 1
move 18 from 2 to 5
move 3 from 4 to 1
move 1 from 1 to 2
move 1 from 6 to 8
move 1 from 7 to 1
move 10 from 1 to 5
move 1 from 1 to 5
move 3 from 8 to 1
move 2 from 1 to 5
move 3 from 6 to 5
move 8 from 2 to 9
move 2 from 9 to 7
move 3 from 3 to 8
move 1 from 4 to 8
move 3 from 5 to 3
move 15 from 5 to 8
move 4 from 6 to 1
move 2 from 7 to 4
move 9 from 5 to 7
move 1 from 6 to 8
move 5 from 3 to 5
move 5 from 7 to 5
move 3 from 1 to 5
move 2 from 4 to 8
move 3 from 1 to 6
move 20 from 5 to 4
move 1 from 7 to 6
move 21 from 8 to 2
move 1 from 3 to 7
move 2 from 4 to 2
move 1 from 7 to 1
move 18 from 2 to 8
move 3 from 9 to 2
move 1 from 6 to 4
move 1 from 1 to 9
move 8 from 8 to 6
move 4 from 8 to 2
move 1 from 2 to 6
move 7 from 8 to 5
move 2 from 5 to 3
move 1 from 9 to 5
move 5 from 2 to 4
move 1 from 3 to 7
move 2 from 5 to 7
move 4 from 4 to 9
move 2 from 5 to 9
move 6 from 2 to 8
move 3 from 7 to 3
move 2 from 5 to 4
move 4 from 8 to 2
move 2 from 7 to 4
move 7 from 6 to 4
move 1 from 8 to 4
move 3 from 6 to 7
move 2 from 7 to 2
move 7 from 9 to 7
move 1 from 9 to 2
move 3 from 3 to 6
move 3 from 7 to 4
move 2 from 7 to 9
move 6 from 4 to 1
move 3 from 7 to 9
move 1 from 8 to 5
move 1 from 3 to 6
move 3 from 9 to 4
move 2 from 6 to 4
move 3 from 9 to 1
move 4 from 2 to 8
move 1 from 8 to 5
move 9 from 1 to 2
move 1 from 6 to 5
move 1 from 7 to 2
move 1 from 8 to 1
move 2 from 8 to 9
move 1 from 9 to 8
move 1 from 5 to 7
move 1 from 7 to 6
move 1 from 9 to 8
move 1 from 6 to 3
move 26 from 4 to 3
move 1 from 5 to 8
move 3 from 6 to 3
move 7 from 4 to 3
move 1 from 1 to 3
move 1 from 4 to 8
move 13 from 3 to 1
move 1 from 3 to 4
move 12 from 2 to 5
move 20 from 3 to 2
move 1 from 4 to 1
move 4 from 5 to 7
move 1 from 7 to 8
move 9 from 5 to 2
move 5 from 1 to 5
move 21 from 2 to 8
move 5 from 8 to 4
move 4 from 5 to 2
move 6 from 1 to 7
move 1 from 5 to 4
move 4 from 3 to 1
move 6 from 1 to 3
move 1 from 1 to 9
move 6 from 8 to 7
move 4 from 8 to 2
move 4 from 2 to 7
move 5 from 4 to 1
move 8 from 8 to 4
move 1 from 9 to 6
move 18 from 7 to 6
move 15 from 6 to 5
move 2 from 6 to 8
move 2 from 6 to 3
move 8 from 3 to 7
move 15 from 5 to 7
move 3 from 4 to 9
move 12 from 2 to 3
move 3 from 9 to 4
move 6 from 7 to 9
move 9 from 4 to 5
move 10 from 3 to 5
move 9 from 5 to 2
move 14 from 7 to 8
move 14 from 8 to 5
move 4 from 2 to 4
move 1 from 4 to 6
move 2 from 8 to 4
move 3 from 8 to 9
move 18 from 5 to 1
move 1 from 5 to 9
move 1 from 7 to 4
move 5 from 5 to 9
move 3 from 2 to 4
move 13 from 9 to 2
move 13 from 2 to 6
move 1 from 7 to 3
move 3 from 3 to 1
move 9 from 6 to 5
move 1 from 7 to 8
move 20 from 1 to 8
move 2 from 2 to 8
move 5 from 6 to 9
move 15 from 8 to 7
move 3 from 5 to 3
move 5 from 1 to 3
move 2 from 3 to 4
move 3 from 9 to 5
move 4 from 5 to 2
move 4 from 5 to 7
move 3 from 4 to 9
move 10 from 7 to 8
move 2 from 9 to 4
move 1 from 5 to 6
move 8 from 7 to 9
move 1 from 6 to 7
move 6 from 3 to 4
move 12 from 9 to 8
move 1 from 1 to 5
move 2 from 7 to 8
move 1 from 7 to 5
move 1 from 9 to 5
move 2 from 2 to 9
move 11 from 8 to 1
move 7 from 1 to 5
move 3 from 1 to 6
move 5 from 8 to 9
move 8 from 4 to 3
move 4 from 4 to 6
move 5 from 9 to 3
move 4 from 4 to 5
move 2 from 6 to 7
move 1 from 9 to 5
move 2 from 7 to 4
move 12 from 5 to 2
move 8 from 8 to 9
move 8 from 8 to 6
move 9 from 6 to 2
move 4 from 9 to 2
move 1 from 5 to 1
move 5 from 2 to 1
move 2 from 5 to 4
move 5 from 2 to 5
move 5 from 5 to 6
move 3 from 4 to 7
move 11 from 2 to 7
move 2 from 2 to 1
move 4 from 3 to 7
move 2 from 2 to 4
move 6 from 1 to 4
move 1 from 2 to 8
move 2 from 9 to 5
move 4 from 4 to 3
move 5 from 4 to 1
move 2 from 2 to 1
move 1 from 8 to 5
move 14 from 7 to 6
move 3 from 9 to 2
move 15 from 6 to 8
move 4 from 1 to 3
move 2 from 2 to 3
move 1 from 1 to 7
move 2 from 3 to 5
move 4 from 5 to 4
move 1 from 3 to 5
move 5 from 1 to 6
move 12 from 6 to 7
move 7 from 8 to 4
move 12 from 7 to 9
move 4 from 7 to 9
move 1 from 2 to 8
move 12 from 9 to 4
move 23 from 4 to 3
move 1 from 6 to 5
move 3 from 9 to 3
move 1 from 7 to 9
move 1 from 9 to 1
move 1 from 9 to 7
move 42 from 3 to 1
move 3 from 5 to 4
move 5 from 1 to 3
move 3 from 4 to 7
move 1 from 1 to 9
move 4 from 3 to 8
move 1 from 3 to 7
move 1 from 9 to 1
move 2 from 7 to 8
move 8 from 1 to 6
move 2 from 7 to 5
move 9 from 1 to 2
move 5 from 2 to 3
move 3 from 2 to 4
move 20 from 1 to 2
move 1 from 1 to 5
move 1 from 6 to 7
move 3 from 4 to 7
move 2 from 3 to 6
move 3 from 6 to 1
move 1 from 6 to 4
move 2 from 1 to 6
move 3 from 5 to 9
move 1 from 4 to 3
move 2 from 7 to 4
move 6 from 8 to 4
move 1 from 1 to 9
move 1 from 2 to 9
move 2 from 8 to 7
move 3 from 6 to 2
move 5 from 7 to 5
move 4 from 2 to 5
move 4 from 4 to 6
move 3 from 9 to 6
move 4 from 3 to 1
move 1 from 9 to 2
move 7 from 8 to 9
move 4 from 2 to 4
move 2 from 1 to 7
move 3 from 4 to 5
move 4 from 2 to 4
move 1 from 7 to 4
move 4 from 2 to 9
move 7 from 4 to 3
move 1 from 7 to 3
move 6 from 2 to 3
move 2 from 1 to 5
move 10 from 3 to 6
move 2 from 6 to 1
move 2 from 2 to 7
move 2 from 3 to 1
move 1 from 7 to 8
move 11 from 5 to 3
move 2 from 3 to 1
move 4 from 6 to 1
move 1 from 4 to 6
move 8 from 3 to 4
move 2 from 5 to 6
move 3 from 3 to 5
move 1 from 8 to 4
move 1 from 4 to 9
move 2 from 6 to 1
move 1 from 5 to 1
move 9 from 4 to 3
move 5 from 6 to 9
move 5 from 6 to 7
move 13 from 9 to 3
move 5 from 1 to 8
move 4 from 8 to 4
move 10 from 3 to 2
move 3 from 6 to 1
move 2 from 7 to 9
move 1 from 8 to 3
move 1 from 7 to 3
move 1 from 9 to 5
move 1 from 6 to 3
move 7 from 2 to 4
move 3 from 5 to 2
move 8 from 3 to 5
move 7 from 4 to 3
move 5 from 9 to 7
move 1 from 7 to 1
move 9 from 1 to 8
move 9 from 5 to 8
move 2 from 7 to 8
move 3 from 8 to 1
move 10 from 3 to 6
move 1 from 1 to 6
move 5 from 1 to 7
move 3 from 2 to 8
move 7 from 8 to 6
move 7 from 8 to 6
move 1 from 3 to 5
move 5 from 7 to 9
move 4 from 8 to 4
move 3 from 2 to 8
move 1 from 7 to 8
move 3 from 3 to 9
move 3 from 7 to 4
move 1 from 7 to 2
move 9 from 9 to 1
move 5 from 1 to 9
move 4 from 8 to 6
move 1 from 2 to 7
move 1 from 5 to 3
move 1 from 3 to 7
move 1 from 1 to 9
move 1 from 1 to 7
move 5 from 9 to 6
move 2 from 7 to 6
move 10 from 4 to 8
move 1 from 4 to 2
move 1 from 4 to 1
move 1 from 9 to 2
move 3 from 1 to 2
move 1 from 7 to 3
move 1 from 2 to 1
move 16 from 6 to 3
move 9 from 6 to 1
move 6 from 6 to 1
move 5 from 6 to 1
move 3 from 8 to 1
move 11 from 3 to 4
move 1 from 6 to 2
move 3 from 8 to 2
move 4 from 1 to 6
move 5 from 3 to 2
move 1 from 2 to 5
move 1 from 8 to 5
move 5 from 8 to 3
move 4 from 6 to 9
move 2 from 9 to 6
move 3 from 3 to 9
move 1 from 5 to 7
move 5 from 1 to 6
move 3 from 6 to 4
move 2 from 2 to 9
move 8 from 4 to 2
move 9 from 1 to 7
move 3 from 3 to 5
move 3 from 5 to 7
move 12 from 7 to 1
move 5 from 4 to 6
move 1 from 4 to 5
move 7 from 1 to 8
move 5 from 9 to 3
move 1 from 7 to 4
move 10 from 1 to 8
move 1 from 4 to 8
move 4 from 6 to 8
move 1 from 6 to 9
move 2 from 5 to 1
move 4 from 3 to 4
move 1 from 1 to 8
move 4 from 4 to 7
move 2 from 1 to 8
move 4 from 6 to 1
move 3 from 9 to 5
move 1 from 6 to 5
move 1 from 3 to 7
move 24 from 8 to 6
move 3 from 6 to 5
move 4 from 6 to 7
move 1 from 1 to 7
move 7 from 7 to 6
move 7 from 5 to 3
move 13 from 6 to 8
move 3 from 1 to 2
move 7 from 6 to 3
move 12 from 2 to 4
move 4 from 6 to 9
move 6 from 3 to 1
move 1 from 2 to 4
move 2 from 8 to 7
move 2 from 2 to 9
move 6 from 3 to 4
move 12 from 8 to 2
move 18 from 2 to 5
move 10 from 4 to 3
move 4 from 7 to 3
move 5 from 4 to 7
move 3 from 5 to 2
move 4 from 7 to 9
move 1 from 5 to 4
move 3 from 2 to 1
move 4 from 3 to 6
move 7 from 5 to 6
move 2 from 5 to 7
move 5 from 1 to 7
move 9 from 7 to 6
move 8 from 9 to 8
move 1 from 1 to 3
move 1 from 3 to 1
move 10 from 3 to 9
move 8 from 8 to 4
move 1 from 3 to 8
move 1 from 1 to 3
move 6 from 9 to 1
move 5 from 5 to 3
move 5 from 3 to 6
move 1 from 8 to 9
move 19 from 6 to 2
move 13 from 4 to 1
move 4 from 1 to 5
move 6 from 2 to 1
move 2 from 9 to 4
move 1 from 3 to 1
move 9 from 2 to 3
move 4 from 5 to 1
move 5 from 9 to 6
move 4 from 3 to 4
move 3 from 2 to 7
move 2 from 4 to 8
move 6 from 1 to 9
move 1 from 8 to 6
move 4 from 1 to 5
move 3 from 4 to 5
move 1 from 7 to 2
move 11 from 1 to 6
move 1 from 2 to 7
move 5 from 3 to 7
move 1 from 3 to 4
move 1 from 4 to 8
move 3 from 5 to 6
move 8 from 1 to 7
move 1 from 8 to 9
move 1 from 6 to 9
move 1 from 8 to 5
move 11 from 6 to 5
move 12 from 5 to 2
move 1 from 5 to 2
move 8 from 7 to 3
move 1 from 5 to 6
move 2 from 5 to 6
move 3 from 7 to 1
move 6 from 2 to 6
move 1 from 3 to 1
move 1 from 4 to 1
move 4 from 6 to 2
move 5 from 1 to 5
move 10 from 2 to 3
move 2 from 9 to 4
move 4 from 5 to 8
move 2 from 2 to 7
move 12 from 6 to 7
move 1 from 8 to 2
move 10 from 3 to 4
move 2 from 3 to 5
move 1 from 3 to 1
""";
	md"Real input definition."
end

# ╔═╡ d1bfd0e7-f8bb-47a2-9553-369b2164d22e
struct Command
	num::Int
	src::Int
	dest::Int
end

# ╔═╡ f85db33b-02a8-4eac-9b4c-f2ced84ec12c
function parse_input(s)
	sts, cmds = split(s, "\n\n")
	stacks = []
	stack_lines = split(sts, "\n")
	for m ∈ eachmatch(r"\d+", last(stack_lines))
		push!(stacks, Stack{Char}())
	end
	for line ∈ reverse(stack_lines[1:end-1])
		for i ∈ 1:length(stacks)
			pos = (i-1)*4+1
			box = line[pos:pos+2]
			m = match(r"^(?:\[([A-Z])\]|   )$", box) 
			if m == nothing
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
		if m == nothing
			continue
		end
		push!(commands, Command(map(n -> parse(Int, n), m.captures)...))
	end
	stacks, commands
end

# ╔═╡ 203e83f9-aef7-40b4-86c5-893dc2f787c7
function apply1(stacks, cmd)
	for i ∈ 1:cmd.num
		push!(stacks[cmd.dest], pop!(stacks[cmd.src]))
	end
end

# ╔═╡ 57b8614d-c9fc-42da-a2a9-ec677f2b9537
function part1(s)
	stacks, cmds = parse_input(s)
	for cmd ∈ cmds
		apply1(stacks, cmd)
	end
	join(first.(stacks))
end

# ╔═╡ af2f7479-2d2d-488d-8ea5-a96222f66fdc
part1(input)

# ╔═╡ a4a0df6c-7600-443d-8bdc-4fbf5d5d8c9b
function apply2(stacks, cmd)
	moving = Char[]
	for i ∈ 1:cmd.num
		push!(moving, pop!(stacks[cmd.src]))
	end
	for el ∈ reverse(moving)
		push!(stacks[cmd.dest], el)
	end
end

# ╔═╡ f85c6859-39be-4192-adac-834e1dee9633
function part2(s)
	stacks, cmds = parse_input(s)
	for cmd ∈ cmds
		apply2(stacks, cmd)
	end
	join(first.(stacks))
end

# ╔═╡ 694bcfa9-a4d6-4e17-adc1-bbb93f61e57f
part2(input)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataStructures = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"

[compat]
DataStructures = "~0.18.13"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "5a896dd2d0ff25ca4c1b15e3bcb710a969e917d6"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "00a2cccc7f098ff3b66806862d275ca3db9e6e5a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.5.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"
"""

# ╔═╡ Cell order:
# ╟─e76416b6-39ec-4303-af11-110bd44a7d11
# ╟─556d4562-4ecb-4f2e-84e4-ae7b3d4d71fe
# ╠═d1bfd0e7-f8bb-47a2-9553-369b2164d22e
# ╠═5db9900f-6b18-4f47-89fb-63663ed443b9
# ╠═f85db33b-02a8-4eac-9b4c-f2ced84ec12c
# ╠═203e83f9-aef7-40b4-86c5-893dc2f787c7
# ╠═57b8614d-c9fc-42da-a2a9-ec677f2b9537
# ╠═af2f7479-2d2d-488d-8ea5-a96222f66fdc
# ╠═a4a0df6c-7600-443d-8bdc-4fbf5d5d8c9b
# ╠═f85c6859-39be-4192-adac-834e1dee9633
# ╠═694bcfa9-a4d6-4e17-adc1-bbb93f61e57f
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
