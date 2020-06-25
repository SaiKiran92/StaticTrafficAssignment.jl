
function path(parentmx::AbstractMatrix{U}, orig::U, dest::U) where {U<:Integer}
    path = Vector{Tuple{U,U}}()
    currnode = dest
    while currnode != orig
        prevnode = parentmx[orig,currnode]
        push!(path, (prevnode, currnode))
        currnode = prevnode
    end
    reverse(path)
end

function pathto(parents::AbstractVector, dest::U) where {U<:Integer}
    path = Vector{Tuple{U,U}}()
    currnode = dest
    while true #currnode != orig
        prevnode = parents[currnode]
        if currnode == prevnode
            break
        end
        push!(path, (prevnode, currnode))
        currnode = prevnode
    end
    reverse(path)
end
