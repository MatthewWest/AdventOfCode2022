module AdventOfCode2022
import Printf.@sprintf

solved = 1:8
for day ∈ solved
    padded = @sprintf("%02d", day)
    include(joinpath("src", "day$padded.jl"))
end

end # module AdventOfCode2022