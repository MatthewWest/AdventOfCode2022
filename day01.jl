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

function get_input(filename)
    open(filename) do f
        elves = Array{Array{Int}}(undef, 0)
        elf = Array{Int}(undef, 0)
        while ! eof(f)
            line = readline(f)
            if line == ""
                push!(elves, elf)
                elf = Int[]
            else
                push!(elf, parse(Int, line))
            end
        end
    end
    elves
end

function part1(input_file = "day01input.txt")
    elves = get_input(input_file)
    maximum(sum.(elves))
end

function part2(input_file = "day01input.txt")
    elves = get_input(input_file)
    calories = sum.(elves)
    n = length(calories)
    sum(partialsort(calories, n-2:n))
end

function bothparts(input_file = "day01input.txt")
    elves = get_input(input_file)
    calories = sum.(elves)
    n = length(calories)
    top3 = sum(partialsort(calories, n-2:n))
    (maximum(sum.(elves)), top3)
end