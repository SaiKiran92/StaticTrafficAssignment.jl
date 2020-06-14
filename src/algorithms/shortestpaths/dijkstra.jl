function dijkstra(network::MetaDiGraph, src::U, costmx::AbstractMatrix{T}, updatecondn::V; kwargs...) where {U<:Integer, T<:Real, V<:Function}
    nnodes = nv(network)
    costs = fill(typemax(T), nnodes)
    parents = zeros(U, nnodes)

    P = PriorityQueue{U,T}()

    P[src] = costs[src] = 0
    parents[src] = 0

    while !isempty(P)
        u = dequeue!(P)

        for v in outneighbors(network, u)
            #if updatecondn(u, v, src, costs[u], costs[v], costmx[u,v], kwargs...)
            #vcost = costs[v]
            #altcost = costs[u] + costmx[u,v]
            if updatecondn(u, v, src, costs, costmx, kwargs...)
            #if updatecondn(u, v, src, vcost, altcost, kwargs...)
                P[v] = costs[v] = costs[u] + costmx[u,v]
                #P[v] = costs[v] = altcost
                parents[v] = u
            end
        end
    end

    return (costs = costs, parents = parents)
end

#shortpathcondn(u, v, src, ucost, vcost, linkcost) = (vcost > ucost + linkcost)
shortpathcondn(u, v, src, costs, costmx) = (costs[v] > costs[u] + costmx[u,v])
#shortpathcondn(u, v, src, vcost, altcost) = (vcost > altcost)
dijkstra(network::MetaDiGraph, src::U, costmx::AbstractMatrix{T}) where {T<:Real, U<:Integer} = dijkstra(network, src, costmx, shortpathcondn)

#ftcondn(u, v, src, ucost, vcost, linkcost; firstthroughnode) = (vcost > ucost + linkcost) && ((u < firstthroughnode) || (u == src))
ftcondn(u, v, src, costs, costmx; firstthroughnode) = (costs[v] > costs[u] + costmx[u,v]) && ((u >= firstthroughnode) || (u == src))
dijkstra(network::MetaDiGraph, src::U, costmx::AbstractMatrix{T}, firstthroughnode::U) where {T<:Real, U<:Integer} = dijkstra(network, src, costmx, ftcondn; firstthroughnode=firstthroughnode)

longpathcondn(u, v, src, costs, costmx; firstthroughnode, flowmx) = (flowmx[u,v] > 0.) && (costs[v] < costs[u] + costmx[u,v]) && ((u >= firstthroughnode) || (u == src))
dijkstra(network::MetaDiGraph, src::U, costmx::AbstractMatrix{T}, firstthroughnode::U, flowmx::AbstractMatrix) where {T<:Real, U<:Integer} = dijkstra(network, src, costmx, longpathcondn; firstthroughnode=firstthroughnode, flowmx=flowmx)

function dijkstra(network::MetaDiGraph, sources::AbstractVector{U}, costmx::AbstractMatrix{T}) where {T<:Real, U<:Integer}
    nsources = length(sources)
    costs, parents = zeros(T, nsources, nv(network)), zeros(U, nsources, nv(network))
    @sync @distributed for i in 1:nsources
        res = dijkstra(network, sources[i], costmx)
        costs[i,:] = res[1]
        parents[i,:] = res[2]
    end

    return (costs = costs, parents = parents)
end
