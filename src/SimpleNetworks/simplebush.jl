mutable struct SimpleBush{T<:Integer} <: AbstractBush{T}
    net::AbstractNetwork{T}
    src::T
    linkactivity::Vector{Bool}
    orderednodes::Union{Nothing, Vector{T}} # `nothing` when not updated
end

function SimpleBush{T}(net::AbstractNetwork{T}, src::U, costfn::CostFunction) where {T<:Integer, U<:Integer}
    nlinks = numlinks(net)
    linkactivity = fill(false, nlinks)
    _, parentvec = dijkstra(net, src, costfn(zeros(nlinks)).costs)

    for l in links(net)
        i,j,lidx = upn(l), dwn(l), idx(net,l)
        if parentvec[j] == i
            linkactivity[lidx] = true
        end
    end

    SimpleBush{T}(net, src, linkactivity, nothing)
end

src(b::SimpleBush) = b.src
net(b::SimpleBush) = b.net

for fn in (:numnodes, :numzones, :numsources, :numsinks, :sources, :sinks, :zones)
    @eval $fn(b::SimpleBush) = $fn(b.net)
end

for fn in (:issource, :issink, :throughflowallowed, :props)
    @eval $fn(b::SimpleBush{T}, i::U) where {T<:Integer, U<:Integer} = $fn(b.net, i)
end

function idx(b::SimpleBush, args...; warn=true, kwargs...)
    i = idx(b.net, args...; kwargs...)
    if !b.linkactivity[i]
        @warn "Link $i inactive in this bush!"
    end
    return i
end

numlinks(b::SimpleBush) = sum(b.linkactivity)
links(b::SimpleBush) = links(b.net)[b.linkactivity]

function outneighbors(b::SimpleBush, i::U) where {U<:Integer}
    adjlist, points = fstar(b.net)
    rv = adjlist[i]
    activeones = b.linkactivity[points[i]:(points[i+1]-1)]
    return rv[activeones]
end

function inneighbors(b::SimpleBush, j::U) where {U<:Integer}
    adjlist, points = bstar(b.net)
    rv = adjlist[j]
    activeones = b.linkactivity[idx.(Ref(b.net), adjlist[j], Ref(j))]
    return rv[activeones]
end

function outdegree(b::SimpleBush, i::U) where {U<:Integer}
    _,points = fstar(b.net)
    sum(b.linkactivity[points[i]:(points[i+1]-1)])
end

function indegree(b::SimpleBush, j::U) where {U<:Integer}
    adjlist,_ = bstar(b.net)
    return sum(b.linkactivity[idx.(Ref(b.net), adjlist[j], Ref(j))])
end

add_link!(b::SimpleBush, i::U) where {U<:Integer} = (b.orderednodes = nothing; b.linkactivity[i] = true;)
rem_link!(b::SimpleBush, j::U) where {U<:Integer} = (b.orderednodes = nothing; b.linkactivity[j] = false;)

add_link!(b::SimpleBush, l::AbstractLink) = add_link!(b, idx(b.net, l))
rem_link!(b::SimpleBush, l::AbstractLink) = rem_link!(b, idx(b.net, l))

add_link!(b::SimpleBush, i::U, j::U) where {U<:Integer} = add_link!(b, idx(b.net, i, j))
rem_link!(b::SimpleBush, i::U, j::U) where {U<:Integer} = rem_link!(b, idx(b.net, i, j))

add_link!(b::SimpleBush, args...; kwargs...) = error("Can only activate an existing link for a bush!")
rem_link!(b::SimpleBush, args...; kwargs...) = error("Can only deactivate an existing link for a bush!")

add_zone!(b::SimpleBush, args...; kwargs...) = error("Cannot add a zone to a bush!")
rem_zone!(b::SimpleBush, args...; kwargs...) = error("Cannot remove a zone from a bush!")

has_link(b::SimpleBush, i, j) = has_link(b.net, i, j) && b.linkactivity[idx(b.net, i, j)]

function orderednodes(b::SimpleBush) # NOTE: it updates bush, when b.orderednodes is not updated
    if b.orderednodes == nothing
        b.orderednodes = invperm(topologicalorder(b))
    end
    b.orderednodes
end
