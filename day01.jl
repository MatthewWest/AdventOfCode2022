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


function parse_input(s)
    [sum(map(c -> parse(Int, c), split(elf))) for elf in split(s, "\n\n")]
end

get_input(filename) = read(filename, String)

function part1(s)
    maximum(parse_input(s))
end

function part2(s)
    elves = parse_input(s)
    n = length(elves)
    sum(partialsort(elves, n-2:n))
end

input = get_input("day01input.txt")
part1(input)
part2(input)
