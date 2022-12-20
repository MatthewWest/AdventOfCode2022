module Day20

INPUT_PATH = joinpath(@__DIR__, "../data/day20.txt")

mutable struct ListNode{T}
    data::T
    prev::Union{ListNode{T}, Nothing}
    next::Union{ListNode{T}, Nothing}
end

mutable struct LinkedList{T}
    head::ListNode{T}
    tail::ListNode{T}
end

function parse_input(s, multiplier)
    nums = map(line -> parse(Int, line) * multiplier, split(rstrip(s)))
    nodes = ListNode{Int}[]
    for num ∈ nums
        push!(nodes, ListNode(num, nothing, nothing))
    end
    nodes[1].prev = last(nodes)
    for i ∈ 1:(length(nodes) - 1)
        nodes[i].next = nodes[i+1]
        nodes[i+1].prev = nodes[i]
    end
    nodes[end].next = nodes[1]
    LinkedList(nodes[1], nodes[end]), nodes
end

function remove!(tmp)
    tmp.next.prev = tmp.prev
    tmp.prev.next = tmp.next
end

function insert_after!(node, to_insert)
    next = node.next
    node.next = to_insert
    next.prev = to_insert
    to_insert.prev = node
    to_insert.next = next
end

function move!(to_move, list, n_nodes)
    n = to_move.data
    if n == 0
        return
    else
        # Since we remove a node, we need to modulus by n_nodes - 1
        n = mod1(n, n_nodes-1)
    end

    # Special handling to keep track of where the boundary of the circular list is
    if to_move == list.head
        list.head = to_move.next
    elseif to_move == list.tail
        list.tail = to_move.prev
    end

    # Remove the node we're moving
    remove!(to_move)

    # Move forward however many moves
    node = to_move
    for _ ∈ 1:n
        node = node.next
    end

    # Insert after
    insert_after!(node, to_move)

    # If we reached the end, the moved node is the new tail
    if node == list.tail
        list.tail = to_move
    end
end

function findall(f::Function, list::LinkedList{T}) where {T}
    node = list.head
    is = ListNode[]
    while true
        if f(node.data)
            push!(is, node)
        end
        if node == list.tail
            break
        end
        node = node.next
    end
    is
end

function find_grove_coordinates(list::LinkedList{T}) where {T}
    zero = findall(iszero, list) |> only
    sum = 0

    curr = zero
    for i ∈ 1:3000
        curr = curr.next
        if i ∈ Set((1000, 2000, 3000))
            sum += curr.data
        end
    end
    sum
end

function part1(input = read(INPUT_PATH, String))
    list, nodes = parse_input(input, 1)
    n_nodes = length(nodes)
    for node ∈ nodes
        move!(node, list, n_nodes)
    end
    sum(find_grove_coordinates(list))
end

function part2(input = read(INPUT_PATH, String))
    multiplier = 811589153
    list, nodes = parse_input(input, multiplier)
    n_nodes = length(nodes)
    for _ ∈ 1:10
        for node ∈ nodes
            move!(node, list, n_nodes)
        end
    end
    sum(find_grove_coordinates(list))
end

end # module Day20