module Day02
export part1, part2

INPUT_PATH = joinpath(@__DIR__, "../data/day02.txt")

function result1(opp, me)
    if opp == "A"
        if me == "X"
            return 3
        elseif me == "Y"
            return 6
        elseif me == "Z"
            return 0
        end
    elseif opp == "B"
        if me == "X"
            return 0
        elseif me == "Y"
            return 3
        elseif me == "Z"
            return 6
        end
    elseif opp == "C"
        if me == "X"
            return 6
        elseif me == "Y"
            return 0
        elseif me == "Z"
            return 3
        end
    end
end

function choice_score(me)
    if me == "X"
        return 1
    elseif me == "Y"
        return 2
    elseif me == "Z"
        return 3
    end
end

function score1(round)
    opp, me = split(round, " ")
    result1(opp, me) + choice_score(me)
end

function part1(input = read(INPUT_PATH, String))
    rounds = split(rstrip(input), "\n")
    sum(map(score1, rounds))
end

function choice_score2(me)
    if me == "A"
        return 1
    elseif me == "B"
        return 2
    elseif me == "C"
        return 3
    end
end

function result_score(result)
    if result == "X"
        return 0
    elseif result == "Y"
        return 3
    elseif result == "Z"
        return 6
    end
end

function get_choice(opp, result)
    # need to lose
    if result == "X"
        if opp == "A"
            return "C"
        elseif opp == "B"
            return "A"
        elseif opp == "C"
            return "B"
        end
    elseif result == "Y"
        return opp
    elseif result == "Z"
        if opp == "A"
            return "B"
        elseif opp == "B"
            return "C"
        elseif opp == "C"
            return "A"
        end
    end
end

function score2(round)
    opp, result = split(round, " ")
    me = get_choice(opp, result)
    result_score(result) + choice_score2(me)
end

function part2(input = read(INPUT_PATH, String))
    rounds = split(rstrip(input), "\n")
    sum(map(score2, rounds))
end

end # module Day02
