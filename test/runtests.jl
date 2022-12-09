using AdventOfCode2022
using Test

@testset "Day 1" begin
    test_input = """1000
2000
3000

4000

5000
6000

7000
8000
9000

10000
"""
    @test AdventOfCode2022.Day01.part1(test_input) == 24000
    @test AdventOfCode2022.Day01.part2(test_input) == 45000
end

@testset "Day 2" begin
    test_input = """A Y
B X
C Z
"""
    @test AdventOfCode2022.Day02.part1(test_input) == 15
    @test AdventOfCode2022.Day02.part2(test_input) == 12
end

@testset "Day 3" begin
    test_input = """vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw
"""    
    @test AdventOfCode2022.Day03.part1(test_input) == 157
    @test AdventOfCode2022.Day03.part2(test_input) == 70
end

@testset "Day 4" begin
    test_input = """2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8
"""
    @test AdventOfCode2022.Day04.part1(test_input) == 2
    @test AdventOfCode2022.Day04.part2(test_input) == 4
end

@testset "Day 5" begin
    test_input = """    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2"""
    @test AdventOfCode2022.Day05.part1(test_input) == "CMZ"
    @test AdventOfCode2022.Day05.part2(test_input) == "MCD"
end

@testset "Day 6" begin
    @test AdventOfCode2022.Day06.part1("mjqjpqmgbljsphdztnvjfqwrcgsmlb") == 7
    @test AdventOfCode2022.Day06.part1("bvwbjplbgvbhsrlpgdmjqwftvncz") == 5
    @test AdventOfCode2022.Day06.part1("nppdvjthqldpwncqszvftbrmjlhg") == 6
    @test AdventOfCode2022.Day06.part1("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg") == 10
    @test AdventOfCode2022.Day06.part1("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw") == 11

    @test AdventOfCode2022.Day06.part2("mjqjpqmgbljsphdztnvjfqwrcgsmlb") == 19
    @test AdventOfCode2022.Day06.part2("bvwbjplbgvbhsrlpgdmjqwftvncz") == 23
    @test AdventOfCode2022.Day06.part2("nppdvjthqldpwncqszvftbrmjlhg") == 23
    @test AdventOfCode2022.Day06.part2("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg") == 29
    @test AdventOfCode2022.Day06.part2("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw") == 26
end

@testset "Day 7" begin
    test_input = raw"""$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k
"""
    @test AdventOfCode2022.Day07.part1(test_input) == 95437
    @test AdventOfCode2022.Day07.part2(test_input) == 24933642
end

@testset "Day 8" begin
    test_input = """30373
25512
65332
33549
35390"""
    @test AdventOfCode2022.Day08.part1(test_input) == 21
    @test AdventOfCode2022.Day08.part2(test_input) == 8
end


@testset "Day 9" begin
    test_input1 = """R 4
    U 4
    L 3
    D 1
    R 4
    D 1
    L 5
    R 2"""
    @test AdventOfCode2022.Day09.part1(test_input1) == 13

    @test AdventOfCode2022.Day09.part2(test_input1) == 1
    test_input2 = """R 5
    U 8
    L 8
    D 3
    R 17
    D 10
    L 25
    U 20"""
    @test AdventOfCode2022.Day09.part2(test_input2) == 36
end