struct SimpleBush{T<:Integer} <: AbstractBush{T}
    net::AbstractNetwork{T}
    src::T
    linkactivity::Vector{Bool}
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

    SimpleBush{T}(net, src, linkactivity)
end

src(b::SimpleBush) = b.src
net(b::SimpleBush) = b.net

for fn in (:numnodes, :numzones, :numsources, :numsinks, :sources, :sinks, :zones, :issource, :issink, :throughflowallowed, :props)
    @eval $fn(b::SimpleBush, args...; kwargs...) = $fn(b.net, args...; kwargs...)
end

function idx(b::SimpleBush, args...; kwargs...)
    i = idx(b.net, args...; kwargs...)
    if !b.linkactivity[i]
        @warn "Link inactive in this bush!"
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
    activeones = b.linkactivity[points[i]:(points[i+1]-1)]
    return rv[activeones]
end

function outdegree(b::SimpleBush, i::U) where {U<:Integer}
    _,points = fstar(b.net)
    sum(b.linkactivity[points[i]:(points[i+1]-1)])
end

function indegree(b::SimpleBush, j::U) where {U<:Integer}
    _,points = bstar(b.net)
    sum(b.linkactivity[points[j]:(points[j+1]-1)])
end

add_link!(b::SimpleBush, i::U) where {U<:Integer} = (b.linkactivity[i] = true;)
rem_link!(b::SimpleBush, j::U) where {U<:Integer} = (b.linkactivity[j] = false;)

add_link!(b::SimpleBush, args...; kwargs...) = error("Can only activate an existing link for a bush!")
rem_link!(b::SimpleBush, args...; kwargs...) = error("Can only deactivate an existing link for a bush!")

add_zone!(b::SimpleBush, args...; kwargs...) = error("Cannot add a zone to a bush!")
rem_zone!(b::SimpleBush, args...; kwargs...) = error("Cannot remove a zone from a bush!")
