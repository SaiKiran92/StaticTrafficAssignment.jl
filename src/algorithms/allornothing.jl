function allornothing(network::AbstractNetwork,
                      trips::AbstractMatrix{U},
                      costs::AbstractVector{T};
                      basedon::Symbol = :link) where {T<:Real, U<:Real}
    # Initialization
    nnodes, nlinks, nzones = numnodes(network), numlinks(network), numzones(network)
    zonelist = zones(network)
    zoneids = id.(zonelist)

    flows, addflows! = begin
        if basedon == :link
            flows = zeros(nlinks)
            flows, ((src, snk, lidx, v) -> (flows[lidx] += v;))
        elseif (basedon == :origin) || (basedon == :source)
            flows = zeros(nlinks, nzones)
            flows, ((src, snk, lidx, v) -> (flows[lidx,src] += v;))
        end
    end

    # Computing shortest paths
    _, parentmx = dijkstra(network, zoneids, costs)

    # Determining flows
    tripswaiting = copy(trips)
    for src in zoneids
        for snk in zoneids
            t = tripswaiting[src,snk]
            if isapprox(t, 0.) | (src == snk)
                continue
            end
            tripswaiting[src,snk] = 0.

            # Finding the shortest path
            path = findpath(parentmx, src, snk)

            # Assigning flows
            for l in path
                addflows!(src, snk, idx(network, l), t)
                try
                    t += tripswaiting[l[2],snk]
                    tripswaiting[l[2],snk] = 0.
                catch BoundsError
                end
            end
        end
    end
    return flows
end

allornothing(network::AbstractNetwork, trips::AbstractMatrix{T}, costfn::CostFunction; basedon::Symbol = :link) where {T<:Real} = allornothing(network, trips, costfn(zeros(numlinks(network))).costs; basedon=basedon)
