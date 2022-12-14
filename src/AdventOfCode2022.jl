module AdventOfCode2022
import Printf.@sprintf

solved = union(collect(1:15), collect(20:22))
for day ∈ solved
    padded = @sprintf("%02d", day)
    include(joinpath(@__DIR__, "day$padded.jl"))
end

end # module AdventOfCode2022
