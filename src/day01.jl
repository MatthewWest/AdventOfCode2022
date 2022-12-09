# Copyright 2022 Google LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
module Day01
export part1, part2

INPUT_PATH = joinpath(@__DIR__, "../data/day01.txt")

function parse_input(s)
    elves = Array{Array{Int}}(undef, 0)
    elf = Array{Int}(undef, 0)
    lines = split(s, "\n")
    for line ∈ lines
        if line == ""
            push!(elves, elf)
            elf = Int[]
        else
            push!(elf, parse(Int, line))
        end
    end
    elves
end

function part1(input = read(INPUT_PATH, String))
    elves = parse_input(input)
    maximum(sum.(elves))
end

function part2(input = read(INPUT_PATH, String))
    elves = parse_input(input)
    calories = sum.(elves)
    n = length(calories)
    sum(partialsort(calories, n-2:n))
end

end # module Day01