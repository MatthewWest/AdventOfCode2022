module Day09

INPUT_PATH = joinpath(@__DIR__, "../data/day09.txt")

function follow(old_tail_pos, head_to)
    tx, ty = old_tail_pos
    hx, hy = head_to
    # adjacent, no move
    if abs(hx - tx) <= 1 && abs(hy - ty) <= 1
        return tx, ty
    end

    # same row or column, 2 steps away
    if (tx == hx || ty == hy) && (abs(hx - tx) == 2 || abs(hy - ty) == 2)
        dx, dy = sign(hx - tx), sign(hy - ty)
        return tx + dx, ty + dy
    end

    # not touching, not in the same row or column
    if (abs(hx - tx) > 1 || abs(hy - ty) > 1) && (tx != hx && ty != hy)
        dx, dy = sign(hx - tx), sign(hy - ty)
        return tx + dx, ty + dy
    end
    error("Unrecognized move: tail at $old_tail_pos, head moving from $head_from to $head_to")
end

function get_step(dir)
    if dir == "U"
        step = (0, 1)
    elseif dir == "D"
        step = (0, -1)
    elseif dir == "L"
        step = (-1, 0)
    elseif dir == "R"
        step = (1, 0)
    end
    step
end

function path_tail_positions(cmds)
    hpos = 0, 0
    tpos = 0, 0
    tail_positions = Set{Tuple{Int, Int}}()
    push!(tail_positions, tpos)
    for line ∈ split(cmds, "\n")
        parts = split(line)
        dir, dist = parts[1], parse(Int, parts[2])
        step = get_step(dir)
        for _ ∈ 1:dist
            new_hpos = hpos .+ step
            new_tpos = follow(tpos, new_hpos)
            hpos, tpos = new_hpos, new_tpos
            push!(tail_positions, tpos)
        end
    end
    tail_positions
end

function part1(input = read(INPUT_PATH, String))
    length(path_tail_positions(rstrip(input)))
end

function print_rope(links)
    xs, ys = map(first, links), map(last, links)
    min_x, max_x = min(minimum(xs), -5), max(maximum(xs), 5)
    min_y, max_y = min(minimum(ys), -5), max(maximum(ys), 5)
    positions = Dict{Tuple{Int, Int}, Char}()
    for (i, link) ∈ Iterators.reverse(enumerate(links))
        c = i == 1 ? 'H' : "$(i-1)"[1]
        positions[link] = c
    end
    for y ∈ max_y:-1:min_y
        for x ∈ min_x:max_x
            if (x, y) ∈ keys(positions)
                print(positions[(x, y)])
            elseif (x, y) == (0, 0)
                print("s")
            else
                print(".")
            end
        end
        print("\n")
    end
    print("\n")
end

function path_n_long_tail_positions(cmds, n; debug=false)
    links = [(0, 0) for _ ∈ 1:n]
    tail_positions = Set{Tuple{Int, Int}}()
    push!(tail_positions, last(links))
    for line ∈ split(cmds, "\n")
        parts = split(line)
        dir, dist = parts[1], parse(Int, parts[2])
        step = get_step(dir)
        for _ ∈ 1:dist
            for (i, link) ∈ enumerate(links)
                if i == 1
                    links[i] = link .+ step
                else
                    links[i] = follow(link, links[i-1])
                end
            end
            push!(tail_positions, last(links))
        end
        if debug
            print_rope(links)
        end
    end
    tail_positions
end

function part2(input = read(INPUT_PATH, String); debug=false)
    length(path_n_long_tail_positions(rstrip(input), 10; debug=debug))
end

end # module Day09
