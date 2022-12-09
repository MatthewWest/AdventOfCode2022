module Day07
export part1, part2

INPUT_PATH = joinpath(@__DIR__, "../data/day07.txt")

struct File
	size::Int
	name::String
	# Dir, but we can't type it because Julia doesn't support mutually dependent types
	parent
end

mutable struct Dir
	name::String
	files::Vector{File}
	dirs::Vector{Dir}
	parent::Union{Dir,Nothing}
end

function parse_input(s)
	root = nothing
	current = nothing
	in_ls = false
	for line ∈ split(s, "\n")
		if line == ""
			continue
		end
		if startswith(line, "\$")
			if startswith(line, "\$ cd")
				cdmatch = match(r"^\$ cd (.+)$", line)
				dirname = cdmatch.captures[1]
				if dirname == "/"
					new_dir = Dir("/", File[], Dir[], nothing)
					current = new_dir
					root = current
					in_ls = false
				elseif dirname == ".."
					current = current.parent
				else
					@assert match(r"[a-z]+", dirname) !== nothing "malformed dir name $dirname"
					new_dir = Dir(dirname, File[], Dir[], current)
					push!(current.dirs, new_dir)
					current = new_dir
					in_ls = false
				end
			elseif startswith("\$ ls", line)
				in_ls = true
			end
		else
			if startswith(line, "dir ")
				@assert in_ls "dir found when not in a ls context"
				# We don't actually get any additional information here
			else
				filematch = match(r"^([0-9]+) ([a-z.]+)$", line)
				if filematch === nothing
					error("Unrecognized line $(line)")
				end
				size = parse(Int, filematch.captures[1])
				name = filematch.captures[2]
				f = File(size, name, current)
				push!(current.files, f)
			end
		end
	end
	root
end

function size(dir::Dir)
	n = 0
	if length(dir.dirs) > 0
		n += sum(size.(dir.dirs))
	end
	n += sum(map(f -> f.size, dir.files))
	n
end

function get_descendant_dirs(root::Dir)
	children = root.dirs
	for dir ∈ root.dirs
		children = cat(children, get_descendant_dirs(dir); dims=1)
	end
	children
end

function part1(s = read(INPUT_PATH, String))
	sizes = parse_input(s) |> get_descendant_dirs |> ds -> size.(ds)
	sum(filter(n -> n <= 100000, sizes))
end

function part2(s = read(INPUT_PATH, String))
	total_size = 70_000_000
	needed_size = 30_000_000
	root = parse_input(s)
	need_to_delete = needed_size - (total_size - size(root))

	sizes = size.(get_descendant_dirs(root))
	minimum(filter(n -> n >= need_to_delete, sizes))
end

end # module Day07